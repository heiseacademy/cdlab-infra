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
  resources   = [
    digitalocean_domain.cdlab.urn,
    digitalocean_droplet.jenkins.urn,
    digitalocean_droplet.gitlab.urn,
  ]
}

resource "digitalocean_domain" "cdlab" {
  name    = "cdlab.${var.cdlab_base_domain}"
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

resource "digitalocean_record" "a-record-jenkins" {
  domain = "cdlab.${var.cdlab_base_domain}"
  type   = "A"
  ttl    = "300"
  name   = "jenkins"
  value  = digitalocean_droplet.jenkins.ipv4_address
}

# -------------------------------------------
# Digital Ocean Droplet Gitlab
# -------------------------------------------

resource "digitalocean_droplet" "gitlab" {
  image  = "ubuntu-20-04-x64"
  name   = "gitlab"
  region = "fra1"
  size   = "s-2vcpu-4gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ssh_key.id
  ]
}

resource "digitalocean_record" "a-record-gitlab" {
  domain = "cdlab.${var.cdlab_base_domain}"
  type   = "A"
  ttl    = "300"
  name   = "gitlab"
  value  = digitalocean_droplet.gitlab.ipv4_address
}
