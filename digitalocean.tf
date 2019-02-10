# DigitalOcean authentication token
variable "do_auth_token" {}

variable "do_droplet_name" {}

variable "do_droplet_region" {}

variable "do_droplet_size" {}

variable "cloudflare_email" {}

variable "cloudflare_auth_token" {}

variable "publicntp_dns_record" {}

# Configure DigitalOcean provider

provider "digitalocean" {
    token = "${var.do_auth_token}"
}

# Set up SSH key we'll be connecting with
resource "digitalocean_ssh_key" "default" {
    name        = "PNTP Terraform"
    public_key  = "${file("~/.ssh/id_rsa.pub")}"
}

# Create Droplet that will be our Docker host
resource "digitalocean_droplet" "docker_ntpd" {
    image       = "ubuntu-18-04-x64"
    name        = "${var.do_droplet_name}"
    region      = "${var.do_droplet_region}"
    size        = "${var.do_droplet_size}"
    ssh_keys    = [ "${digitalocean_ssh_key.default.fingerprint}" ]
    ipv6        = true

    provisioner "remote-exec" {
        inline = [
            "apt-get update",
            "DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confnew\" upgrade",
            "DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confnew\" dist-upgrade",
            "apt-get -y autoclean",

            # Docker
            "apt-get -y install apt-transport-https ca-certificates curl software-properties-common",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
            "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable\"",
            "apt update",
            "apt install -y docker-ce",

            # Start Docker image from PublicNTP with NTPd
            "docker run -d --restart unless-stopped --cap-add SYS_RESOURCE --cap-add SYS_TIME -p 123:123/udp publicntp/ntpd:latest -g -n"

            # Add the host to Landscape
        ]

        connection {
            type        = "ssh"
            user        = "root"
            private_key = "${file("~/.ssh/id_rsa")}"
        }
    }
}

# Register IPv4 and IPv6 addresses with CloudFlare
provider "cloudflare" {
    email = "${var.cloudflare_email}"
    token = "${var.cloudflare_auth_token}"
}

# Create CloudFlare IPv4 record
resource "cloudflare_record" "cloudflare_ipv4_record" {
    domain  = "publicntp.org"
    name    = "${var.publicntp_dns_record}"
    type    = "A"
    value   = "${digitalocean_droplet.docker_ntpd.ipv4_address}"
    # ttl     = "86400"
}

# Create CloudFlare IPv6 record
resource "cloudflare_record" "cloudflare_ipv6_record" {
    domain  = "publicntp.org"
    name    = "${var.publicntp_dns_record}"
    type    = "AAAA"
    value   = "${digitalocean_droplet.docker_ntpd.ipv6_address}"
    # ttl     = "86400"
}



# Reboot new host to get new kernel
