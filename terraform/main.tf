terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {
  host        = "unix:///var/run/docker.sock"
  api_version = "1.44"
}

# Create a private virtual network for our node infrastructure
resource "docker_network" "lab_net" {
  name = "ansible_lab_network"
}

# Pull a systemd/SSH-enabled Ubuntu image to simulate remote Linux nodes
resource "docker_image" "ubuntu_node" {
  name = "rastasheep/ubuntu-sshd:18.04"
}

# Provision the node containers
resource "docker_container" "target_nodes" {
  count = var.node_count
  name  = "node-0${count.index + 1}"
  image = docker_image.ubuntu_node.image_id

  networks_advanced {
    name = docker_network.lab_net.name
  }

  ports {
    internal = 22
    external = var.base_ssh_port + count.index
  }
}