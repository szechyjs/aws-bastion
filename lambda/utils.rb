require 'digest'
require_relative 'env'

def user_hash(user)
  Digest::MD5.hexdigest(user)
end

def security_group_name(user)
  "#{cluster_name}/#{user}"
end

def attachment_description(task)
  task_arn = task.task_arn
  attachment_id = task.attachments.first&.id
  identifier = "attachment/#{attachment_id}"
  task_arn.gsub(%r{task/.*}, identifier)
end
