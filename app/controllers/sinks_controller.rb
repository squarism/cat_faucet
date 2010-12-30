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
    @house = House.first
    
    if @house
      @sinks = @house.sinks
      @basement_sink = @sinks.where(:name => "basement").first
    end
  end
  
  def map_json(json_request)
    # if we received a metric data point, save it to the db
    if json_request["type"] == "metric"
      
      # create or get our house object
      # TODO: conf file for Strings here instead of "Dillon"
      house = House.find_or_create_by(:name => "Dillon House")
      
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
          #sink = house.send(sensor).where(:name => json_request["name"]).first
          if !registered_sink.nil?

            # first time sensor has been saved  
            sink = house.sinks.where( { :name => sensor_name } ).first
                      
            if sink.nil?
              sink = house.sinks.create(:name => sensor_name)
              house.save
            end

            # update sensor
            #sink = Sink.find(:first, :conditions => { :name => sensor_name } )
            sink["proximity"] = json_request["proximity"]
            sink["running"] = json_request["running"]
            sink.save
            house.save
            
            render :text => "Saved JSON serial to DB."
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
    #render :text => "This is a test URL for sending a fake sensor message."
    message = '{
       "sensor": "sinks",
       "name": "basement",
       "proximity": "true",
       "running": "true",
       "hash": "ED076287532E86365E841E92BFC50D8C",
       "type": "metric"
     }'
     json_request = JSON.parse(message)
     map_json json_request
  end
    
end
