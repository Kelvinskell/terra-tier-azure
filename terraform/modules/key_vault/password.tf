# Secrets: generate  SQL admin password
resource "random_password" "sql_admin" {
  length           = 32
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?/"  # avoid problematic chars for SQL logins
}
