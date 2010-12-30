class Sink
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  
  validates_uniqueness_of :name
  
  field :running, :type => Boolean
  field :proximity, :type => Boolean
  
end

