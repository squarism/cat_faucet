class SensorsController < ApplicationController
  def create
    @sensor = Sensor.new(params[:sensor])
    
    respond_to do |format|
      if @sensor.save
        format.html { 
          flash[:notice] = 'Sensor was successfully registered.'
          redirect_to sensors_path
        }
        format.xml  { 
          render :xml => @sensor, :status => :created, :location => @sensor
        }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sensor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @sensor = Sensor.find(params[:id])
    @sensor.destroy
    
    respond_to do |format|
      format.html {
        flash[:notice] = 'Sensor was successfully unregistered.'
        redirect_to sensors_path
      }
      format.xml  { head :ok }
    end
    
  end
  
  def index
    @sensors = Sensor.all
  end
  
  def edit
  end
    
  def new
    @sensor = Sensor.new
  end

end
