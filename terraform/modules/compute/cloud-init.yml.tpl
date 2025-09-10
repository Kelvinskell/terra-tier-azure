#cloud-config
hostname: 3-tier-app-server
manage_etc_hosts: true

write_files:
  - path: /usr/local/bin/azure_init.sh
    permissions: '0755'
    owner: root:root
    content: |
      #!/bin/bash
      set -euo pipefail

      # --- Basic network / apt tweaks ---
      echo "nameserver 8.8.8.8" >> /etc/resolv.conf
      apt-get -o Acquire::ForceIPv4=true update -y

      # Change hostname
      echo "3-tier-app-server" > /etc/hostname
      hostnamectl set-hostname 3-tier-app-server

      # --- Install prerequisites ---
      apt-get install -y git binutils curl gnupg lsb-release apt-transport-https ca-certificates

      # Install Azure CLI (official repo)
      curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
      gpg --dearmor | \
      sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

      echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
      sudo tee /etc/apt/sources.list.d/azure-cli.list

      apt-get update -y
      apt-get install -y azure-cli

      # Login to Azure using Managed Identity (VM must have identity and Key Vault access)
      az login --identity >/dev/null 2>&1 || true

      # --- Azure Files ---
      # Template placeholders (will be rendered by Terraform):
      #   ${resource_group}   -> resource group name
      #   ${storage_account}  -> storage account name
      #   ${file_share}       -> file share name
      RESOURCE_GROUP="${resource_group}"
      STORAGE_ACCOUNT="${storage_account}"
      FILE_SHARE="${file_share}"

      apt-get install -y cifs-utils

      STORAGE_KEY=$(az storage account keys list -g "$RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" --query '[0].value' -o tsv 2>/dev/null || echo "")
      if [ -n "$STORAGE_KEY" ]; then
        az storage share create --name "$FILE_SHARE" --account-name "$STORAGE_ACCOUNT" --account-key "$STORAGE_KEY" >/dev/null 2>&1 || true
        mkdir -p /mnt/azurefiles
        mount -t cifs //$${STORAGE_ACCOUNT}.file.core.windows.net/$${FILE_SHARE} /mnt/azurefiles \
          -o vers=3.0,username=$${STORAGE_ACCOUNT},password=$${STORAGE_KEY},dir_mode=0777,file_mode=0777,serverino || true
      else
        echo "Warning: Could not obtain storage account key for $${STORAGE_ACCOUNT}. Skipping Azure Files mount."
      fi

      # --- Key Vault / MySQL secrets ---
      KV_NAME="${kv_name}"

      # Secrets in Key Vault: "mysql-user" and "mysql-pass"
      MYSQL_USER=$(az keyvault secret show --vault-name "$KV_NAME" --name "mysql-user" --query value -o tsv 2>/dev/null || echo "")
      MYSQL_PASS=$(az keyvault secret show --vault-name "$KV_NAME" --name "mysql-pass" --query value -o tsv 2>/dev/null || echo "")

      # MySQL server & DB (placeholders)
      MYSQL_SERVER_NAME="${mysql_server_name}"
      MYSQL_DB_NAME="${mysql_db_name}"

      # Resolve MySQL host (single or flexible server)
      MYSQL_HOST=$(az mysql server show -g "${resource_group}" -n "$MYSQL_SERVER_NAME" --query fullyQualifiedDomainName -o tsv 2>/dev/null || true)
      if [ -z "$MYSQL_HOST" ]; then
        MYSQL_HOST=$(az mysql flexible-server show -g "${resource_group}" -n "$MYSQL_SERVER_NAME" --query fullyQualifiedDomainName -o tsv 2>/dev/null || true)
      fi

      if [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASS" ] || [ -z "$MYSQL_HOST" ]; then
        echo "WARNING: missing MYSQL_USER, MYSQL_PASS or MYSQL_HOST. Check VM managed identity and Key Vault / MySQL resource names."
      fi

      # --- Install app dependencies (VM uses Azure MySQL, no local mysql-server) ---
      apt-get update -y && apt-get upgrade -y
      apt-get install -y python3-flask mysql-client python3-pip python3-venv \
        sox ffmpeg libcairo2 libcairo2-dev python3-dev default-libmysqlclient-dev build-essential

      # --- Clone application repo ---
      cd / || true
      rm -rf /terra-tier-azure
      git clone https://github.com/Kelvinskell/terra-tier-azure.git /terra-tier-azure || true
      cd /terra-tier-azure || true

      # --- Write .env files with secrets from Key Vault ---
      cat > /terra-tier-azure/.env <<EOF
      MYSQL_ROOT_PASSWORD=$${MYSQL_PASS}
      EOF

      mkdir -p /terra-tier-azure/application || true

      cat > /terra-tier-azure/application/.env <<EOF
      MYSQL_DB=$${MYSQL_DB_NAME}
      MYSQL_HOST=$${MYSQL_HOST}
      MYSQL_USER=$${MYSQL_USER}
      DATABASE_PASSWORD=$${MYSQL_PASS}
      MYSQL_ROOT_PASSWORD=$${MYSQL_PASS}
      SECRET_KEY=08dae760c2488d8a0dca1bfb
      API_KEY=f39307bb61fb31ea2c458479762b9acc
      EOF

      # --- Systemd service setup (if present in repo) ---
      if [ -f /terra-tier-azure/newsread.service ]; then
        cp /terra-tier-azure/newsread.service /etc/systemd/system/newsread.service
        systemctl daemon-reload
        systemctl enable newsread
      fi

      # --- Python dependencies and service start ---
      cd /terra-tier-azure || true
      if [ -f requirements.txt ]; then
        pip3 install -r requirements.txt || true
      fi

      if systemctl list-unit-files | grep -q newsread; then
        systemctl start newsread || true
      fi

      echo "Cloud-init script completed."

runcmd:
  - [ "/usr/local/bin/azure_init.sh" ]
