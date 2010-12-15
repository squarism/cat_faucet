#simplest ruby program to read from arduino serial, 
#using Ruby/SerialPort library
#(http://ruby-serialport.rubyforge.org)

require 'serialport'
require 'json'
require 'digest/md5'

#params for serial port
port_str = "/dev/tty.usbserial-A9005bCr"  #may be different for you
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

start_json = false
end_json = false
json_buffer = ""



# Reads from serial and tries to make a JSON string
# NOTE: This is severely limited in that it can't do nested JSON {} brackets inside
# brackets.  I have to read a byte at a time, so sue me.
while true do
  c = sp.getc

  if c == "{" && !start_json
    start_json = true
    json_buffer = c
  else
    if c == "{" && start_json
      raise IOError, "JSON opening bracket found before other closed."
    end
    
    if c != "}"
      json_buffer += c
    end
    
    if c == "}" && start_json
      json_buffer += c
      json_string = json_buffer
      json_object = JSON.parse(json_string)
      
      
      message = json_object['message']
      hash = json_object['hash']
      type = json_object['type']
      
      #puts "MESSAGE: #{message}"
      #puts "HASH: #{hash}"
      #puts "TYPE: #{type}"
      
      
      # the local hash is in lowercase to start
      local_hash = Digest::MD5.hexdigest(message)
      if local_hash.upcase == hash.upcase
        puts "VALID: <#{type}>, payload: #{message}"
      end
      
      
      # clear everything for next loop
      json_buffer = ""
      start_json = false
    elsif c == "}" && !start_json
      raise IOError, "JSON opening bracket found before other closed."
    end
  end  
  
end

sp.close                       #see note 1



