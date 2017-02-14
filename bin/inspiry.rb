require 'httparty'
require 'json'
require 'date'
require 'cgi'

def get_quote
  puts "Getting the Quote of the day."
  resp = HTTParty.get(TSS_URL)
  body = JSON.parse(resp.body)
  author = body["contents"]["quotes"][0]["author"]
  puts "Got a Nice quote from #{author}"
  quote = body["contents"]["quotes"][0]["quote"]
  puts "This wise person says - #{quote}"
  post_message(">#{quote}\n>*<http://www.google.com/search?btnI=I'm+Feeling+Lucky&q=site%3Awikipedia.org%20#{CGI.escape(author)}|#{author}>*")
end

def post_message quote
  puts "Transferring the vibe through Slack!"
  poster = ENV["POST_AS"] || "Quote of the Day"
  img = ENV["IMAGE_URL"] || "https://libcom.org/files/images/library/fist.jpg"
  emoji = ENV["IMAGE_EMOJI"] || ":smile:"
  HTTParty.post SLACK_WEBHOOK, body: {"text" => quote, "username" => poster, "icon_url" => img, "icon_emoji" => emoji}.to_json, headers: {'content-type' => 'application/json'}
  puts "Posted a message. Hope they'd like it."
end

unless ENV['DISABLE_WEEKENDS'] && ['Saturday', 'Sunday'].include?(Date.today.strftime('%A'))
  SLACK_WEBHOOK = ENV["SLACK_WEBHOOK"]

  #Available Categories = ["inspire", "management", "sports", "life", "funny", "love", "art"]
  category = ENV["CATEGORY"] || "inspire"
  TSS_URL = "http://api.theysaidso.com/qod.json?category=#{category}"

  puts "Off to Work.."
  get_quote
  puts "All done for the day."
end
