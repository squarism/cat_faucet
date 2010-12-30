class Sink < Sensor
  field :running, :type => Boolean
  field :proximity, :type => Boolean
  #embedded_in :house, :inverse_of => :sink
end