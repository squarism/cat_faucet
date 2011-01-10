class Sink
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  
  validates_uniqueness_of :name
  
  field :running, :type => Boolean
  field :proximity, :type => Boolean
  field :collected_at, :type => Time
  
  def plot_by_hours
    hours_hash = Hash.new(0)
    
    # count up our hours
    self.versions.each do |v|
      hours_hash[v.collected_at.hour] += 1
    end
    
    hours_hash[self.collected_at.hour] += 1
    
    total = 0
    hours_hash.each_key do |h|
      total += hours_hash[h]
    end

    hours_percentage = Hash.new
    hours_hash.each_key do |h|
      percent = hours_hash[h].to_f / total.to_f
      hours_percentage[h] = (percent.round 2) * 100
    end

    # flot needs an array of arrays for data values
    hours_percentage.to_a    
  end
  
end

