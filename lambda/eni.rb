require 'aws-sdk-ec2'

$ec2 ||= Aws::EC2::Client.new

def describe_network_interfaces(attachment_description)
  puts "Describing network interfaces for #{attachment_description}"
  resp = $ec2.describe_network_interfaces(
    filters: [
      {
        name: 'description',
        values: [attachment_description]
      }
    ]
  )
  resp.network_interfaces
end

def get_public_ip(attachment_description)
  puts "Getting public IP for bastion"
  ints = describe_network_interfaces(attachment_description)
  public_ip = ints.first&.association&.public_ip
  return public_ip if public_ip

  sleep 2 # ENI attachment & IP assignment may take some time
  get_public_ip(attachment_description)
end

def wait_for_eni_deletion(attachment_description)
  puts 'Waiting for ENI deletion'
  ints = describe_network_interfaces(attachment_description)
  if ints.any?
    sleep 2 # ENI destruction may take some time
    wait_for_eni_deletion(attachment_description)
  end
end
