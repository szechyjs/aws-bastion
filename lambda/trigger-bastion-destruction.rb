require 'aws-sdk-lambda'
require 'json'

def handler(event:, context:)
  user = event['requestContext']['identity']['userArn'].split('/').last
  puts "user: #{user}"
  payload = JSON.generate(user: user)

  client = Aws::Lambda::Client.new
  resp = client.invoke(
    function_name: ENV['DESTROY_BASTION_FUNCTION_NAME'],
    invocation_type: 'Event',
    payload: payload
  )
  { statusCode: resp.status_code }
end
