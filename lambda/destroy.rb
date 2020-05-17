require_relative 'task'
require_relative 'sg'

def handler(event:, context:)
  user = event['user']
  puts "user: #{user}"
  task = get_task_for_user(user)
  puts "task: #{task[:task_arn]}"
  stop_task(task) if task
  delete_sg_for_user(user)
  { statusCode: 200 }
end
