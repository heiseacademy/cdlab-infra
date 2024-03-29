data "digitalocean_ssh_key" "ssh_key" {
  name = var.do_ssh_key
}

# -------------------------------------------
# Digital Ocean DNS
# -------------------------------------------

resource "digitalocean_domain" "cdlab" {
  name    = var.cdlab_base_domain
}

# -------------------------------------------
# Digital Ocean Droplet Jenkins
# -------------------------------------------

resource "digitalocean_droplet" "jenkins" {
  image  = "ubuntu-20-04-x64"
  name   = "jenkins"
  region = "fra1"
  size   = "s-2vcpu-4gb"
  ipv6   = false
  ssh_keys = [
    data.digitalocean_ssh_key.ssh_key.id
  ]
}

resource "digitalocean_record" "a-record-jenkins" {
  domain = var.cdlab_base_domain
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
  size   = "s-4vcpu-8gb"
  ipv6   = false
  ssh_keys = [
    data.digitalocean_ssh_key.ssh_key.id
  ]
}

resource "digitalocean_record" "a-record-gitlab" {
  domain = var.cdlab_base_domain
  type   = "A"
  ttl    = "300"
  name   = "gitlab"
  value  = digitalocean_droplet.gitlab.ipv4_address
}

resource "digitalocean_record" "a-record-gitlab-registry" {
  domain = var.cdlab_base_domain
  type   = "A"
  ttl    = "300"
  name   = "registry"
  value  = digitalocean_droplet.gitlab.ipv4_address
}

resource "digitalocean_record" "a-record-gitlab-chartmuseum" {
  domain = var.cdlab_base_domain
  type   = "A"
  ttl    = "300"
  name   = "helmrepo"
  value  = digitalocean_droplet.gitlab.ipv4_address
}

# @-Record for cdlab_base_domain points to gitlab
resource "digitalocean_record" "at-record-cdlab" {
  domain = var.cdlab_base_domain
  type   = "A"
  ttl    = "300"
  name   = "@"
  value  = digitalocean_droplet.gitlab.ipv4_address
}
