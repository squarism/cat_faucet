class Sink
  include Mongoid::Document
  include Mongoid::Timestamps
  
  validates_uniqueness_of :name
  
  field :running, :type => Boolean
  field :proximity, :type => Boolean
  embedded_in :house, :inverse_of => :sink
end