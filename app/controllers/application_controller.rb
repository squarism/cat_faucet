class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # contant of sensor values in json protocol, other TYPES in sensor model
  SENSOR_TYPES = ['sinks', 'pressures']
end
