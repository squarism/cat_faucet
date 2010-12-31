require 'json'

class SinksController < ApplicationController
  
  def update
    respond_to do |format|
      format.json {
        render :nothing => true
        puts "UPDATE"        
      }
    end
  end
  
  
  # we should handle the create/update here for simplicity
  def create
    
    respond_to do |format|
      format.json {
        # parse our body, werk the body
        json_request = JSON.parse(request.body.read)
        map_json json_request 
      }
      
      format.html {
        # looks like this never gets hit
        render :text => "Sorry we don't do HTML yet."
      }
      
    end
  
  end
  
  def index
    @sinks = Sink.all
    @basement_sink = @sinks.where(:name => "basement").first
  end
  
  def map_json(json_request)
    # if we received a metric data point, save it to the db
    if json_request["type"] == "metric"
      
      # sanity check
      sensor = ""
      if SENSOR_TYPES.include?(json_request["sensor"])
        sensor = json_request["sensor"]
        sensor_name = json_request["name"]
        puts "!!!!! #{sensor_name}"
        
        # mapper
        case sensor
        when "sinks"
          registered_sink = Sensor.where(:name => sensor_name).first
                    
          # uses sanity check in send for generic code
          if !registered_sink.nil?

            # find_or_initialize won't save the record now if this is the first sensor run
            sink = Sink.find_or_initialize_by( { :name => sensor_name } )

            # update sensor
            sink.collected_at = Time.new
            sink["proximity"] = json_request["proximity"]
            sink["running"] = json_request["running"]
            sink.save

            # plain text output to console
            #render :text => "Saved JSON serial to DB."
          else
            # TODO: logger here instead
            # throw a 400 bad request response in plain text because we're in json request
            render :text => "Name incorrect in DB.  Please correct in DB or re-register sensor.", :status => 400
          end
        when "pressures"
          # TODO: real stuff here
          puts "Hey cat bed."
        end
        
      else
        # TODO: logger here instead
        # throw a 400 bad request response in plain text because we're in json request
        render :text => "Sensor name incorrect in JSON.", :status => 400
      end
      
    end
  end
  
  def fake
    message = '{
       "sensor": "sinks",
       "name": "basement",
       "proximity": "false",
       "running": "true",
       "hash": "ED076287532E86365E841E92BFC50D8C",
       "type": "metric"
     }'
     json_request = JSON.parse(message)
     map_json json_request
     
     flash[:notice] = "Saved faked JSON serial to DB."
     redirect_to sinks_path
  end
    
end
