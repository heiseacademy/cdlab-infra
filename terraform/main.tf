data "digitalocean_ssh_key" "ssh_key" {
  name = var.do_ssh_key
}

# -------------------------------------------
# Digital Ocean Project
# -------------------------------------------

resource "digitalocean_project" "cdlab" {
  name        = "cdlab"
  description = "Heise Academy - CD Lab"
  environment = "Production"
  resources   = [digitalocean_droplet.jenkins.urn]
}

resource "digitalocean_domain" "cdlab" {
  name       = "cdlab.${var.base_domain}"
}

# -------------------------------------------
# Digital Ocean Droplet Jenkins
# -------------------------------------------

resource "digitalocean_droplet" "jenkins" {
  image  = "ubuntu-20-04-x64"
  name   = "jenkins"
  region = "fra1"
  size   = "s-2vcpu-4gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ssh_key.id
  ]
}

resource "digitalocean_record" "a-record" {
  domain = "cdlab.${var.base_domain}"
  type   = "A"
  ttl    = "300"
  name   = "jenkins"
  value  = digitalocean_droplet.jenkins.ipv4_address
}
