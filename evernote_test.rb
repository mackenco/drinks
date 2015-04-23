require_relative 'evernote_config.rb'

client = EvernoteOAuth::Client.new(consumer_key:OAUTH_CONSUMER_KEY, consumer_secret:OAUTH_CONSUMER_SECRET, sandbox: false)

puts client
