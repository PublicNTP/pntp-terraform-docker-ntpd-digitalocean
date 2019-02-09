# terraform-docker-ntpd-digitalocean

# Overview

Terraform script to launch a droplet that hosts NTPd via Docker on DigitalOcean

# Installation

## Install Terraform

```bash
$ sudo apt-get update
$ sudo apt-get -y install wget unzip
$ cd /tmp
$ wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip 
$ unzip terraform_0.11.11_linux_amd64.zip
$ sudo mv terraform /usr/local/bin
$ rm terraform_0.11.11_linux_amd64.zip
```
