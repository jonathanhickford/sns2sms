require 'sinatra'
require 'sinatra/activerecord'
require 'twilio-ruby'

require 'pp'
require 'uri'
require 'json'

require './config/db'
require './db/migrate/20121022211506_people'

TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID']
TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN'] 
TWILIO_APP_SID = ENV['TWILIO_APP_SID'] 
TWILIO_CALLER_ID =  ENV['TWILIO_CALLER_ID'] 

class Person < ActiveRecord::Base
end

# A hack around multiple routes in Sinatra
def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end


helpers do

  def text_all(message)
    client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
    Person.find_each(:batch_size => 10) do | person |
		logger.info person.name
		client.account.sms.messages.create(
			:from => TWILIO_CALLER_ID,
			:to => person.number,
			:body => message[0..120]
		)
  	end
  end

end



get '/' do
  "Home"
end

# SMS Handler.  Send any incoming SMS to the entire group (inc sender) prefixed with the senders name
# TODO - This should really use the XML Twilio format (it shows as an error in the Twilio console, but it works as-is)
get_or_post '/sms/?' do
  #logger.info pp params

  return [500, {}, "Need a 'Body' and the number this is 'From' (inc. +44)"] if not (params['From'] and params['Body'])
  
  logger.info params['From']
  logger.info params['Body']
  respondent = Person.find_by_number(params['From'])
  message = params['Body']
   
  if respondent
  	message = "#{respondent.name}: " + message
  	logger.info respondent.name
  end
  logger.info message
  text_all(message)
  message
end

# Handler for AWS SNS http reqests.  
get_or_post '/aws/?' do
	request_type = request.env["x-amz-sns-message-type"]
	json = JSON.parse(request.body.read)
	logger.info pp json
	 
	# Handle subscription/unsuscription requests manually through visiting the URL in the logs.
	# TODO - Make this a bit nicer (perhaps SMS the URL to the group)
	if request_type == "SubscriptionConfirmation"
		return 200
	elsif request_type == "UnsubscribeConfirmation"
		return 200
	end
	
	#logger.info json["Subject"]
	#logger.info json["Message"]

	message = "#{json["Subject"]} - #{json["Message"]}"
	logger.info message
	text_all(message)
	message
end




