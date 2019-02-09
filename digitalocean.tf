# DigitalOcean authentication token
variable "do_auth_token" {}

variable "do_droplet_name" {}

variable "do_droplet_region" {}

variable "do_droplet_size" {}

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
            "DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confnew\" dist-upgrade",
            "apt-get -y autoclean",

            # Docker
            "apt-get -y install apt-transport-https ca-certificates curl software-properties-common",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
            "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable\"",
            "apt update",
            "apt install -y docker-ce",

            # NTPd container
            "",
        ]

        connection {
            type        = "ssh"
            user        = "root"
            private_key = "${file("~/.ssh/id_rsa")}"
        }
    }
}

# Update the host to latest Ubuntu


