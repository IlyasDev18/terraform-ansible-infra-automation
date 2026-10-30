terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "lab_net" {
  name = "ansible_lab_network"
}

resource "docker_image" "ubuntu_node" {
  name = "rastasheep/ubuntu-sshd:18.04"
}

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