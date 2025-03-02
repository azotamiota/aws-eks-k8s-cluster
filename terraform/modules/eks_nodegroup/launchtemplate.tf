
data "cloudinit_config" "workers_userdata" {
  for_each = var.node_groups

  gzip          = false
  base64_encode = true
  boundary      = "//"

  part {
    content_type = "text/x-shellscript"
    content = each.value["ami_id"] == "" ? (each.value["container_runtime"] == "dockerd"
      ? templatefile("${path.module}/templates/userdata.sh.tpl",
        {
          pre_userdata       = each.value["pre_userdata"]
          kubelet_extra_args = each.value["kubelet_extra_args"]
        }
        ) : templatefile("${path.module}/templates/runtime-userdata.sh.tpl",
        {
          pre_userdata         = each.value["pre_userdata"]
          kubelet_extra_args   = each.value["kubelet_extra_args"]
          container_runtime    = each.value["container_runtime"]
          additional_disk_size = try(each.value["additional_disk"][0]["disk_size"], 0)
      })
      ) : templatefile("${path.module}/templates/custom.ami.userdata.sh.tpl",
      {
        pre_userdata         = each.value["pre_userdata"]
        kubelet_extra_args   = each.value["kubelet_extra_args"]
        bootstrap_extra_args = each.value["bootstrap_extra_args"]
        cluster_name         = var.cluster_name
        cluster_endpoint     = var.cluster_endpoint
        cluster_auth_base64  = var.cluster_auth_base64
      }
    )
  }
}
resource "aws_launch_template" "workers" {
  for_each = var.node_groups

  name_prefix            = each.value["name"]
  description            = format("EKS Managed Node Group custom LT for %s", each.value["name"])
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = each.value["disk_size"]
      volume_type           = lookup(each.value, "disk_type", null)
      iops                  = lookup(each.value, "disk_iops", null)
      delete_on_termination = true
    }
  }

  dynamic "block_device_mappings" {
    for_each = try(each.value["additional_disk"], [])
    content {
      device_name = block_device_mappings.value.name
      ebs {
        volume_size           = block_device_mappings.value.disk_size
        volume_type           = block_device_mappings.value.disk_type
        iops                  = lookup(block_device_mappings.value, "disk_iops", null)
        delete_on_termination = true
      }
    }
  }

  image_id      = each.value["ami_id"]
  instance_type = each.value["instance_types"]

  monitoring {
    enabled = lookup(each.value, "enable_monitoring", null)
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups = flatten([
      var.node_security_group,
      var.cluster_security_group,
    ])
  }

  user_data = data.cloudinit_config.workers_userdata[each.key].rendered

  # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, each.value["additional_tags"])
  }

  # Supplying custom tags to EKS instances root volumes is another use-case for LaunchTemplates. (doesnt add tags to dynamically provisioned volumes via PVC tho)
  tag_specifications {
    resource_type = "volume"

    tags = merge(var.tags, each.value["additional_tags"])
  }

  # Tag the LT itself
  tags = merge(var.tags, each.value["additional_tags"])

  lifecycle {
    create_before_destroy = true
  }
}
