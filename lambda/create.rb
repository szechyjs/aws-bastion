require_relative 'task'
require_relative 'sg'
require 'json'

def response_body(ip, code = 201)
  {
    body: JSON.generate(
      ip: ip
    ),
    statusCode: code
  }
end

def start_bastion(user, cidr_ip, sg_id = nil)
  sg_id ||= create_sg_for_user(user, cidr_ip)
  run_task_for_user(user, sg_id)
end

def handler(event:, context:)
  identity = event['requestContext']['identity']
  cidr_ip = "#{identity['sourceIp']}/32"
  user = identity['userArn'].split('/').last
  puts "user: #{user}"

  if sg_id = get_sg_id_for_user(user)
    puts "existing sg: #{sg_id}"
    if ip_matches?(sg_id, cidr_ip)
      if task = get_task_for_user(user)
        puts "existing task #{task[:task_arn]}"
        return response_body(task[:bastion_ip], 200)
      else
        puts "no task, reuse existing sg"
        task = start_bastion(user, cidr_ip, sg_id)
      end
    else # ip doesnt match
      if task = get_task_for_user(user)
        puts "existing sg doesn't match, kill it all"
        stop_task(task)
        delete_sg_for_user(user)
        task = start_bastion(user, cidr_ip)
      else
        puts "no task, remove old sg"
        delete_sg_for_user(user)
        task = start_bastion(user, cidr_ip)
      end
    end
  else
    puts "nothing exists, create it all"
    task = start_bastion(user, cidr_ip)
  end

  response_body(task[:bastion_ip])
end
