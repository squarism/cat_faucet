class Sensor
  # these constants are used for dropdown list, other TYPES in app controller
  TYPES = { 'Automatic Sink' => 'sink', 'Pressure Sensor' => 'pressure' }
  
  include Mongoid::Document
  
  validates_inclusion_of :type, :in => Sensor::TYPES.values
  validates_presence_of :type
  validates_presence_of :name
  validates_uniqueness_of :name
  
  field :name, :type => String
  field :type, :type => String
      
end