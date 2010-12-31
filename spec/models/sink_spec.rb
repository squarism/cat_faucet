require "spec_helper"

describe Sink do
  context "with 2 or more versions" do
    it "has only 2 versions" do
      sink = Sink.create(:name => "test")
      sink.running = false
      sink.save
      sink.running = true
      sink.save
      
      sink.reload.versions.size.should eq(2)
      
      # clean up with destroy to get rid of versions[]
      Sink.destroy_all
    end
  end

  context "with 2 or more versions" do
    it "gives back an array for graphing" do
      #dates = Array.new
      
      # fake data
      hour_distributions = ["00:10", "00:11", "0:12", "01:00", "01:59", "2:30", "10:01", "11:15"]
      
      # initial record
      sink = Sink.find_or_initialize_by(:name => "test")
      #sink.running = false
      #sink.save
      
      hour_distributions.each do |hour|
        sink.running = !sink.running
        sink.collected_at=Time.parse("Dec 25 2010 #{hour}")
        sink.save
        #sink.versions[i].updated_at=Date.parse("Dec 25 2010 #{hour}")
      end
                
      # dates.size.should eq(2)
      # 11:15pm is the current version so it won't show up in the versions
      sink.plot_by_hours.should eq({0 => 3, 1 => 2, 2 => 1, 10 => 1})
      #true
      
      # clean up
      Sink.destroy_all
    end
  end

  
end