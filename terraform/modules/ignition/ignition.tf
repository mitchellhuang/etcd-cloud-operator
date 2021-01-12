// Copyright 2017 Quentin Machu & eco authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

data "ignition_config" "main" {
  files = [
    data.ignition_file.eco-config.rendered,
    data.ignition_file.eco-ca.rendered,
    data.ignition_file.eco-crt.rendered,
    data.ignition_file.eco-key.rendered,
    data.ignition_file.e.rendered,
  ]

  systemd = [
    data.ignition_systemd_unit.docker.rendered,
    data.ignition_systemd_unit.locksmithd.rendered,
    data.ignition_systemd_unit.update-engine.rendered,
    data.ignition_systemd_unit.eco.rendered,
    data.ignition_systemd_unit.node-exporter.rendered,
    data.ignition_systemd_unit.selinux-disable-service.rendered,
  ]

  directories = [
    data.ignition_directory.var-lib-eco.rendered,
  ]

  users = [data.ignition_user.core.rendered]
}

data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = var.instance_ssh_keys
}

data "ignition_systemd_unit" "selinux-disable-service" {
  name    = "selinux-disable.service"
  content = file("${path.module}/resources/selinux-disable.service")
}

data "ignition_systemd_unit" "docker" {
  name = "docker.service"

  dropin {
    name    = "10-dockeropts.conf"
    content = "[Service]\nEnvironment=\"DOCKER_OPTS=--log-opt max-size=50m --log-opt max-file=10\"\n"
  }
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data "ignition_systemd_unit" "update-engine" {
  name = "update-engine.service"
  mask = true
}

data "template_file" "eco-service" {
  template = file("${path.module}/resources/eco.service")

  vars = {
    image = var.eco_image
  }
}

data "ignition_systemd_unit" "eco" {
  name    = "eco.service"
  content = data.template_file.eco-service.rendered
}

data "ignition_directory" "var-lib-eco" {
  path = "/var/lib/eco"
}

data "ignition_systemd_unit" "node-exporter" {
  name    = "node-exporter.service"
  content = file("${path.module}/resources/node-exporter.service")
}

data "ignition_file" "eco-config" {
  path       = "/etc/eco/config.yaml"
  mode       = 420

  content {
    content = var.eco_configuration
  }
}

data "ignition_file" "eco-ca" {
  path       = "/etc/eco/ca.crt"
  mode       = 420

  content {
    content = var.eco_ca
  }
}

data "ignition_file" "eco-crt" {
  path       = "/etc/eco/eco.crt"
  mode       = 420

  content {
    content = var.eco_cert
  }
}

data "ignition_file" "eco-key" {
  path       = "/etc/eco/eco.key"
  mode       = 420

  content {
    content = var.eco_key
  }
}

data "ignition_file" "e" {
  path       = "/opt/bin/e"
  mode       = 493

  content {
    content = file("${path.module}/resources/e")
  }
}

data "ignition_config" "blank" {
}

