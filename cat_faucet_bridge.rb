# monitor a serial port connection and post JSON to a rails app
# used to read arduino sensor data and load into mongodb through rails webservice

require 'serialport'
require 'json'
require 'digest/md5'
require 'net/http'
require 'uri'
require 'rubygems'

# Parameters you should change
port_str = "/dev/ttyUSB0"  # may be different for you
rails_url = "http://localhost:8000"       # customize if needed



# Parameters you shouldn't need to change
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

debug_mode = false

# Variables for scope reasons
# TODO: handle Errno::ENOENT if /dev path is wrong
# TODO: print list of available USB devices
serial_port = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
puts "Opened serial port."

start_json = false
json_buffer = ""
json_object = ""


# do JSON HTTP post to rails
def post_json(url, input_json)
  # we don't need the serial hash anymore so we
  # can reuse the serial json payload from the sensor
  input_json.delete "hash"

  # parse our input url
  uri = URI.parse(url)

  # make a new request
  req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})


  # have to format it as json again with .to_json to avoid a
  #   undefined method 'bytesize' for #<Hash: ...
  # error message.
  req.body = input_json.to_json

  response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req)}
  puts "Response #{response.code} #{response.message}: #{response.body}"
end


puts "Listening to serial port."
# Reads from serial and tries to make a JSON string
# NOTE: This is severely limited in that it can't do nested JSON {} brackets inside
# brackets.  I have to read a byte at a time, so sue me.
while true do
  c = serial_port.getc

  if c == "{" && !start_json
    start_json = true
    json_buffer = c
  else
    if c == "{"
      # TODO: just return here instead of exiting the program.
      # Weird serial messages are sent.  Arduino would send double messages on bootup.
    end

    if c != "}"
      json_buffer += c
    end

    if c == "}"
      json_buffer += c
      json_string = json_buffer

      begin
        json_object = JSON.parse(json_string)
      rescue JSON::ParserError => e
        puts e.message
      end

      # example JSON message
      #  {
      #    "sensor": "sinks",
      #    "name": "basement",
      #    "proximity": "false",
      #    "running": "true",
      #    "hash": "ED076287532E86365E841E92BFC50D8C",
      #    "type": "metric"
      #  }

      sensor = json_object['sensor']
      name = json_object['name']
      proximity = json_object['proximity']
      running = json_object['running']
      hash = json_object['hash']
      type = json_object['type']

      # TODO: Hash whole JSON?  Improve this logic.  Only partially validates.
      # hash is "sensor name", ie: "sinks basement"
      # the local hash is in lowercase to start
      # 82C61D54A77D6A90219E4E40CE6C8440 = arduino
      # 82c61d54a77d6a90219e4e40ce6c8440 = ruby
      local_hash = Digest::MD5.hexdigest("#{sensor} #{name}")


      # MD5 feature completely crashing Arduino after two movements.  MD5 is excessive load on the Arduino.
      # So we'll just hardcode this for now and then remove it.
      if hash.upcase == "NOHASH"
        puts "VALID: <#{type}>, proximity:#{proximity} running:#{running}" if debug_mode
        if !json_object["sensor"].nil?

          # ruby switch syntax
          case json_object["sensor"]
          when "sinks"
        		puts "Posting to #{rails_url}/sinks/ --> #{json_object}" if debug_mode
            post_json("#{rails_url}/sinks/", json_object)
          when "pressure"
            post_json("#{rails_url}/pressures/", json_object)
          else
            puts json_object
            puts "No match on serial string.  Not posting JSON/HTTP."
          end
        else
          puts "json_object has no sensor."
        end
      else
        puts "#{local_hash} vs #{hash}"
      end

      # clear everything for next loop
      json_buffer = ""
      start_json = false
    elsif c == "}" && !start_json
      # This will stop the bridge, which is not what you want in "production"
      # This is helpful for debugging though.
      raise IOError, "JSON opening bracket found before other closed." if debug_mode
    end
  end

end

serial_port.close                       #see note 1
