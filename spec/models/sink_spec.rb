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
      
      # clean up
      Sink.delete_all
    end
  end

  context "with 2 or more versions" do
    it "gives back an array for graphing" do
      dates = Array.new
      
      sink = Sink.create(:name => "test")
      sink.running = false
      sink.save
      dates << sink.updated_at
      
      sink.running = true
      sink.save
      dates << sink.updated_at
      
      dates.size.should eq(2)
      
      # clean up
      Sink.delete_all
    end
  end

  
end