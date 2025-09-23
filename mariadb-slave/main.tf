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

// we define it as data source because it is created by the master
data "docker_network" "internal-net-01" {
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

resource "docker_container" "mariadb-slave" {
  image = docker_image.mariadb.name
  name  = "mariadb-slave"

  env = [
    "MYSQL_ROOT_PASSWORD=root",
    "MYSQL_REPLICATION_MODE=slave",
    "MYSQL_REPLICATION_USER=replicauser",
    "MYSQL_REPLICATION_PASSWORD=pass123",
    "MYSQL_MASTER_HOST=mariadb-master",
  ]
    ports {
        internal = 3306
        external = 33007
    }

    volumes {
        host_path      = "${var.PWD}/init-slave.sql"
        container_path = "/docker-entrypoint-initdb.d/init-slave.sql"
        read_only = true
    }

    volumes {
        host_path      = "${var.PWD}/slave.cnf"
        container_path = "/etc/mysql/conf.d/my.cnf"
        read_only      = true
    }

    networks_advanced {
        name = data.docker_network.internal-net-01.name
        aliases = ["mariadb-slave"]
    }
}

