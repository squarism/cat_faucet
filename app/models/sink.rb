class Sink
  include Mongoid::Document
  
  validates_uniqueness_of :name
  
  field :running, :type => Boolean
  field :proximity, :type => Boolean
  embedded_in :house, :inverse_of => :sink
end