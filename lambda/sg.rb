require 'aws-sdk-ec2'
require_relative 'env'
require_relative 'utils'

$ec2 ||= Aws::EC2::Client.new

def authorize_ingress_to_bastion(sg_id, cidr_ip)
  puts "Authorzing ingress from #{cidr_ip} to sg #{sg_id}"
  $ec2.authorize_security_group_ingress({
    cidr_ip: cidr_ip,
    from_port: 22,
    group_id: sg_id,
    ip_protocol: 'tcp',
    to_port: 22
  })
end

def authorize_ingress_via_https(sg_id)
  puts "Authorizing ingress via HTTPS for sg #{sg_id}"
  $ec2.authorize_security_group_ingress({
    group_id: sg_id,
    ip_permissions: [
      {
        from_port: 443,
        ip_protocol: 'tcp',
        to_port: 443,
        user_id_group_pairs: [
          { group_id: sg_id }
        ]
      }
    ]
  })
end

def authorize_bastion_ingress_to_default(sg_id)
  puts "Authorizing ingress from #{sg_id} to default sg #{cluster_vpc_default_security_group_id}"
  $ec2.authorize_security_group_ingress({
    group_id: cluster_vpc_default_security_group_id,
    ip_permissions: [
      {
        ip_protocol: '-1',
        user_id_group_pairs: [
          { group_id: sg_id }
        ]
      }
    ]
  })
end

def revoke_bastion_ingress_to_default(sg_id)
  puts "Revoking ingress from #{sg_id} to default sg #{cluster_vpc_default_security_group_id}"
  $ec2.revoke_security_group_ingress({
    group_id: cluster_vpc_default_security_group_id,
    ip_permissions: [
      {
        ip_protocol: '-1',
        user_id_group_pairs: [
          { group_id: sg_id }
        ]
      }
    ]
  })
end

def ip_matches?(sg_id, cidr_ip)
  puts "Checking whether ingress IP matches #{cidr_ip} for sg #{sg_id}"
  resp = $ec2.describe_security_groups({
    group_ids: [sg_id],
    filters: [
      {
        name: 'ip-permission.cidr',
        values: [cidr_ip] 
      }
    ]
  })
  resp.security_groups.any?
end

def get_sg_id_for_user(user)
  puts "Getting existing security group for #{user}"
  resp = $ec2.describe_security_groups({
    filters: [
      {
        name: 'vpc-id',
        values: [cluster_vpc_id]
      },
      {
        name: 'group-name',
        values: [security_group_name(user)]
      }
    ]
  })
  resp.security_groups.first&.group_id
end

def create_sg_for_user(user, cidr_ip)
  puts "Creating security group for #{user} with ingress from #{cidr_ip}"
  resp = $ec2.create_security_group({
    description: "Bastion access to #{service_name} for #{user}",
    group_name: security_group_name(user),
    vpc_id: cluster_vpc_id
  })
  sg_id = resp.group_id
  authorize_ingress_to_bastion(sg_id, cidr_ip)
  authorize_ingress_via_https(sg_id)
  authorize_bastion_ingress_to_default(sg_id)
  sg_id
end

def delete_sg_for_user(user)
  sg_id = get_sg_id_for_user(user)
  return unless sg_id

  revoke_bastion_ingress_to_default(sg_id)
  puts "Deleting security group for #{user}"
  $ec2.delete_security_group({
    group_id: sg_id
  })
end
