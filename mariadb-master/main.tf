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

resource "docker_image" "mariadb" {
  name         = "mariadb:11"
}

resource "docker_network" "internal-net-01" {
  name = "internal-net-01"
}

variable "PWD" {
  type   = string
  default = ""
}

variable "MYSQL_ROOT_PASSWORD" {
    type    = string
    default = "root"
}

variable "MYSQL_REPLICATION_USER" {
    type    = string
    default = "replicauser"
  
}

variable "MYSQL_REPLICATION_PASSWORD" {
    type    = string
    default = "pass123"
}

resource "docker_container" "mariadb-master" {
  image = docker_image.mariadb.name
  name  = "mariadb-master"

  env = [
    "MYSQL_ROOT_PASSWORD=root",
    "MYSQL_REPLICATION_MODE=master",
    "MYSQL_REPLICATION_USER=replicauser",
    "MYSQL_REPLICATION_PASSWORD=pass123",
  ]
    ports {
        internal = 3306
        external = 33006
    }
    volumes {
        host_path      = "${var.PWD}/init-master.sql"
        container_path = "/docker-entrypoint-initdb.d/init-master.sql"
        read_only = true
    }

    volumes {
        host_path      = "${var.PWD}/master.cnf"
        container_path = "/etc/mysql/conf.d/my.cnf"
        read_only      = true
    }

    networks_advanced {
        name = docker_network.internal-net-01.name
        aliases = ["mariadb-master"]
    }
}
