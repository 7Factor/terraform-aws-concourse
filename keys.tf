resource "tls_private_key" "session_signing_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "tsa_host_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "worker_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_secretsmanager_secret" "web_keys" {
  name = "${var.conc_key_name}-web-keys"
}

resource "aws_secretsmanager_secret_version" "web_keys" {
  secret_id     = aws_secretsmanager_secret.web_keys.id
  secret_string = jsonencode({
    session_signing_key    = tls_private_key.session_signing_key.private_key_pem,
    tsa_host_key           = tls_private_key.tsa_host_key.private_key_pem,
    authorized_worker_keys = tls_private_key.worker_key.public_key_pem,
  })
}

resource "aws_secretsmanager_secret" "worker_keys" {
  name = "${var.conc_key_name}-worker-keys"
}

resource "aws_secretsmanager_secret_version" "worker_keys" {
  secret_id     = aws_secretsmanager_secret.worker_keys.id
  secret_string = jsonencode({
    worker_key     = tls_private_key.worker_key.private_key_pem,
    tsa_public_key = tls_private_key.tsa_host_key.public_key_pem,
  })
}
