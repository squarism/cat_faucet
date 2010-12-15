class Pressure
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type => String
  field :proximity, :type => Boolean
  field :reading, :type => Float
  embedded_in :house, :inverse_of => :pressure
end