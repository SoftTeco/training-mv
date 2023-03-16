terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address  = "ghcr.io"
    username = "${var.github_host}"
    password = "${var.github_access_token}"
  }
}

data "docker_registry_image" "docker-github-runner-lin" {
  name = "${var.runner_image}"
}

resource "docker_image" "crash-js-app" {
  name          = data.docker_registry_image.docker-github-runner-lin.name
  pull_triggers = [data.docker_registry_image.docker-github-runner-lin.sha256_digest]
}
