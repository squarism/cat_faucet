class Sink
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  
  validates_uniqueness_of :name
  
  field :running, :type => Boolean
  field :proximity, :type => Boolean
  field :collected_at, :type => Time
  
  def plot_by_hours
    hours = Hash.new(0)
    
    # count up our hours
    self.versions.each do |v|
      hours[v.collected_at.hour] += 1
    end
    
    hours
  end
  
end

