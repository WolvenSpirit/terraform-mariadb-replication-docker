

terraform {
    required_providers {
        docker = {
        source  = "kreuzwerker/docker"
        version = "2.22.0"
        }
    }
}

provider "docker" {
    host = "unix:///var/run/docker.sock"
  }

  resource "docker_image" "proxysql" {
    name         = "proxysql/proxysql:2.4.4" 
  }

data "docker_network" "internal-net-01" {
    name = "internal-net-01"
  }

variable "PWD" {
    type   = string
    default = ""
}

resource "docker_container" "proxysql" {
    image = docker_image.proxysql.name
    name  = "proxysql"

    env = [
      "PROXYSQL_ADMIN_USERNAME=admin",
      "PROXYSQL_ADMIN_PASSWORD=admin",
      "PROXYSQL_ADMIN_PORT=6032",
    ]

    ports {
        internal = 6032
        external = 6032
    }

    ports {
        internal = 6033
        external = 6033
    }

    volumes {
        host_path      = "${var.PWD}/proxysql/proxysql.cnf"
        container_path = "/etc/proxysql.cnf"
        read_only = true
    }

    depends_on = [
        data.docker_network.internal-net-01
    ]
    networks_advanced {
        name = data.docker_network.internal-net-01.name
        aliases = ["proxysql"]
    } 
}