class Sensor
  TYPES = { 'Automatic Sink' => 'sink', 'Pressure Sensor' => 'pressure' }
  
  include Mongoid::Document
  include Mongoid::Versioning
  
  validates_inclusion_of :type, :in => Sensor::TYPES.values
  validates_presence_of :type
  validates_presence_of :name
  
  field :name, :type => String
  field :type, :type => String
      
end