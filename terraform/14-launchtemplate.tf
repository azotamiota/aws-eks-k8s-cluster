
data "cloudinit_config" "workers_userdata" {
  gzip          = false
  base64_encode = true
  boundary      = "//"

  part {
    content_type = "text/x-shellscript"
    content      = templatefile("./templates/userdata.sh.tpl", 
      {
        pre_userdata       = ""
        kubelet_extra_args = ""
        additional_disk_size = 0
      })
  }
}

resource "aws_launch_template" "workers" {
  name_prefix            = "eks-portfolio-launchtemplate-workers"
  description            = "EKS Managed Node Group custom LaunchTemplate"
  update_default_version = true
  user_data              = data.cloudinit_config.workers_userdata.rendered

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 50
      volume_type = "gp3"
    }
  }
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.eks_portfolio_cluster_sg.id]
  }

  # dynamic "block_device_mappings" {
  #   for_each = try(each.value["additional_disk"], [])
  #   content {
  #     device_name = block_device_mappings.value.name
  #     ebs {
  #       volume_size           = block_device_mappings.value.disk_size
  #       volume_type           = block_device_mappings.value.disk_type
  #       iops                  = lookup(block_device_mappings.value, "disk_iops", null)
  #       delete_on_termination = true
  #     }
  #   }
  # }

  # image_id      = each.value["ami_id"]
  # instance_type = each.value["instance_types"]

  # monitoring {
  #   enabled = lookup(each.value, "enable_monitoring", null)
  # }



  # # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
  # tag_specifications {
  #   resource_type = "instance"

  #   tags = merge(var.tags, each.value["additional_tags"])
  # }

  # # Supplying custom tags to EKS instances root volumes is another use-case for LaunchTemplates. (doesnt add tags to dynamically provisioned volumes via PVC tho)
  # tag_specifications {
  #   resource_type = "volume"

  #   tags = merge(var.tags, each.value["additional_tags"])
  # }

  # Tag the LT itself
  tags = merge(tomap({ "Name" = "eks-portfolio-launch-template" }), var.permanent_tags)


  lifecycle {
    create_before_destroy = true
  }
}
