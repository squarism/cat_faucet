class Sink
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type => String
  field :running, :type => Boolean
  field :proximity, :type => Boolean
  embedded_in :house, :inverse_of => :sink
end