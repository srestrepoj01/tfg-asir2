# Informacion general del proyecto
project_name = "mastodon-docker"
region       = "eu-west-3"

# Acceso SSH
ssh_key_name       = "mastodon-key"
allowed_ssh_cidrs  = ["0.0.0.0/0"]

# Credenciales de RDS
db_username = "mastodonuser"
db_password = "9NEhbx6nKlsD"

# Variables opcionales 
instance_type      = "t2.medium"
instance_count     = 2

private_key_path = "D:\\Work\\MastodonDeploy\\mastodon-key.pem"

alarm_email = "notifications@srestrepoj-mastodon.com"