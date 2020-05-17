require 'aws-sdk-ecs'
require_relative 'utils'
require_relative 'env'
require_relative 'eni'

$ecs ||= Aws::ECS::Client.new

def bastion_task(task)
  att_desc = attachment_description(task)
  {
    task_arn: task.task_arn,
    attachment_description: att_desc,
    bastion_ip: get_public_ip(att_desc)
  }
end

def get_task_for_user(user)
  resp = $ecs.list_tasks({
    cluster: cluster_name,
    started_by: user_hash(user)
  })
  if resp.task_arns.length > 0
    resp = $ecs.describe_tasks(
      cluster: cluster_name,
      tasks: resp.task_arns
    )
    return bastion_task(resp.tasks.first)
  end
end

def run_task_for_user(user, sg_id)
  puts "Running bastion for #{user}"
  resp = $ecs.run_task({
    cluster: cluster_name,
    task_definition: task_family,
    count: 1,
    started_by: user_hash(user),
    launch_type: 'FARGATE',
    network_configuration: {
      awsvpc_configuration: {
        subnets: cluster_subnet_ids.split(','),
        security_groups: [sg_id],
        assign_public_ip: 'ENABLED'
      }
    },
    overrides: {
      container_overrides: [
        name: container_name,
        environment: [
          {
            name: 'USER_NAME',
            value: user
          }
        ]
      ]
    }
  })
  bastion_task(resp.tasks.first)
end

def stop_task(task)
  $ecs.stop_task({
    task: task[:task_arn],
    cluster: cluster_name,
    reason: 'Requested by user'
  })
  wait_for_eni_deletion(task[:attachment_description])
end
