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
    @data = request.body.read
    
    
    respond_to do |format|
      format.json {
        # parse our body, werk the body
        json_request = JSON.parse(@data)
                
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
              render :text => "Saved JSON serial to DB."
            else
              # TODO: logger here instead
              render :text => "Name incorrect in DB.  Please correct in DB or re-register sensor.", :status => 400
            end
  
          else
            # TODO: logger here instead
            render :text => "Sensor name incorrect in JSON.", :status => 400
          end

          
        end

      }
    end
  end
    
end
