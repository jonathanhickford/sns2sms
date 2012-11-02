# SNS2SMS #

## Intro ##
This app takes SNS notifications from AWS and relays the message component on to a group of international phone numbers using SMS messaging.  Replies to the SMSs will be resent to the entire group.  It uses the Twilio web service and is packaged ready to run in heroku.  This will run on the free tiers of Heroku and Twilio while you test it out.

A sample use cases would be alerating a 24 hour 'on call' ops team to an issue on an SNS channel.  A single team member can then respond to the group saying they are on the issue, and respond to the group when it is fixed 

## Caveats ##

*   It's not my fault if this doesn't work and you don't get texts in a critical situation
*   Heroku is is US-East 1, Twilio are in US-East-1.  Don't reply on this to monitor AWS US-East-1...


## Usage ##

1.   Register on Twilio
     1.   Setup a Twilio Number
	 2.   Verify your mobile number (and any others as required)
     3.   Create a new TWIML app, leave th eednpoints blank for now
2.   Install Heroku Tool Chain
3.   Clone this repo
4.   Create a heroku app
     1.  Run heroku create in the cloneed directory
	 1.  Add a postgres DB, 
	 1.  Run the pg:info command to find the connection details, note the COLOR for use in susequent commands
	 3.  Promote the postgress DB to the primary DB ( in maintaince mode)
	 2.  Add the Adminium admin interface (if you fancy)
	 4.  Add the four config key value pairs below using your Twilio settings
5.  Push the app to heroku
6.  Run a remote Rake tasks to run the satabase migrations
6.  Add the endpoint URLs to the Twilio app in the Twilio dashboard
5.  Use the admin interface on Adminium to add phonenumbers to the 'People' table.  Phone numbers must be in the format '+447555555555', e.g. start with a '+' and  have no spaces.  They must also be validated numbers with Twilio if you are using the demo product
7.  Subscribe an SNS channel using http to the sms endpoint in the app
8.  View the Heroku logs to pull out the validate URL to confirm the subscription
9.  Visit the confirmation URL
10.  Test by sending a message to the SNS channel in the AWS console
11.  Test by replying to that message to see it distributed among all users
 
```bash
$ git clone git://github.com/shareandenjoy/sns2sms.git
$ cd sns2sms

# Basic Setup
# See https://devcenter.heroku.com/articles/quickstart
# See https://devcenter.heroku.com/articles/git
# See https://devcenter.heroku.com/articles/ruby
$ heroku create

# Adding Database
# See https://devcenter.heroku.com/articles/heroku-postgres-addon
$ heroku addons:add heroku-postgresql
$ heroku pg:info
=== HEROKU_POSTGRESQL_BLACK
Plan         Ronin
Status       available
Data Size    5.1 MB
Tables       0
PG Version   9.0.5
Created      2011-10-10 17:59 UTC
$ heroku pg:credentials BLACK
$ heroku maintenance:on
$ heroku pg:info HEROKU_POSTGRESQL_BLACK
$ heroku pg:promote HEROKU_POSTGRESQL_BLACK
$ heroku maintenance:off

# Adding the Admin Interface
# See https://devcenter.heroku.com//articles/adminium
$ heroku addons:add adminium
$ heroku plugins:install git://github.com/isc/heroku-adminium
$ heroku adminium

# Connecting to your Twilio Account
# See https://devcenter.heroku.com/articles/config-vars
$ heroku config:add TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxx
$ heroku config:add TWILIO_AUTH_TOKEN=yyyyyyyyyyyyyyyyy
$ heroku config:add TWILIO_APP_SID=APzzzzzzzzzzzzzzzzzz
$ heroku config:add TWILIO_CALLER_ID=+15556667777

# Deploy the App
$ git push heroku master

# Create the DB
$ heroku rake db:migrate

# Add your Users to the People table (don't forget to verify numbers in Twilio first)
$ heroku addons:open adminium

# Open the App
# heroku open

# View the logs to look for the SNS config URL
# See https://devcenter.heroku.com/articles/logging
# heroku logs
````
	

 
 
 
 
## Improvement Ideas ##
 
*   Cascade the SMS messages down an ordered list of numbers, if somebody responds that they will 'own' the issue within 1 minutes it stops texting, otherwise it tries the next number
 
 