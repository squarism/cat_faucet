# TODO: remove me after integrating with cat_bridge.rb (arduino serial watcher)
# json post to rails test

require 'net/http'
require 'uri'
require 'rubygems'
require 'json'

# do JSON HTTP post to rails
def post_json(url, input_json)
  
  # we don't need the serial hash anymore so we
  # can reuse the serial json payload from the sensor
  input_json.delete "hash"
  
  # parse our input url
  uri = URI.parse(url)
  
  # make a new request
  req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})

  
  # have to format it as json again with .to_json to avoid a
  #   undefined method 'bytesize' for #<Hash: ...
  # error message.
  req.body = input_json.to_json
  
  response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req)}
  puts "Response #{response.code} #{response.message}: #{response.body}"  
end


# MAIN

# test input string, respresents string from serial
input_string = '
{
  "sensor": "sinks",
  "name": "basement",
  "proximity": "false",
  "running": "true",
  "hash": "ED076287532E86365E841E92BFC50D8C",
  "type": "metric"
}
'

# handle munged data
begin
  input_json = JSON.parse(input_string)
rescue JSON::ParserError => e
  puts e.message
end

# mapping here?

rails_url = "http://localhost:3000"
if !input_json["sensor"].nil?

  # ruby switch syntax  
  case input_json["sensor"]
  when "sinks"
    post_json("#{rails_url}/sinks/", input_json)
  when "pressure"
    post_json("#{rails_url}/pressures/", input_json)
  else
    puts "No match on serial string.  Not posting JSON/HTTP."
  end
    
end
  

# register a sensor
def register
end
  


