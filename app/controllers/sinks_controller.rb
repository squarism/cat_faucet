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
                
        # if we received a metric data point, save it to the db
        if json_request["type"] == "metric"
          
          # create or get our house object
          # TODO: conf file for Strings here instead of "Dillon"
          house = House.find_or_create_by(:name => "Dillon House")
          
          # sanity check
          sensor = ""
          if SENSOR_TYPES.include?(json_request["sensor"])
            sensor = json_request["sensor"]
            
            # uses sanity check in send for generic code
            sink = house.send(sensor).where(:name => json_request["name"]).first
            if !sink.nil?
              sink["proximity"] = json_request["proximity"]
              sink["running"] = json_request["running"]
              puts "saving"
              sink.save
              house.save
              render :text => "Saved JSON serial to DB."
            else
              # TODO: logger here instead
              # throw a 400 bad request response
              render :text => "Name incorrect in DB.  Please correct in DB or re-register sensor.", :status => 400
            end
            
          else
            # TODO: logger here instead
            # throw a 400 bad request response
            render :text => "Sensor name incorrect in JSON.", :status => 400
          end
          
        end
      }
      
      format.html {
        # looks like this never gets hit
        render :text => "Sorry we don't do HTML yet."
      }
      
    end
  
  end
  
  def index
    @house = House.first
    @sinks = @house.sinks
    @basement_sink = @sinks.where(:name => "basement").first
  end
    
end
