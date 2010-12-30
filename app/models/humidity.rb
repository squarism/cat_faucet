class Humidity
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type => String
  field :units, :type => String
  field :reading, :type => Float
  #embedded_in :house, :inverse_of => :humidity
end