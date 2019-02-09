# terraform-docker-ntpd

# Overview

Terraform scripts to launch Docker-based NTPd on multiple hosting platforms

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

# Perform install

## DigitalOcean

Generate a DigitalOcean read/write token under the "API" section of the console.

```bash
$ terraform init
$ terraform apply \
> 
> -var 'do_auth_token=abc...xyz' \
> -var 'do_droplet_name=<hostname>' \
> -var 'do_droplet_region=<region code>' \
> -var 'do_droplet_size=<instance code>' 

  [When prompted, type "yes" and hit enter]

``` 
