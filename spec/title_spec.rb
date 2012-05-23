# encoding: utf-8
require_relative "./spec_helper"

describe Title do
  before(:all) do
    BHLIndexer::Config.respond_to?(:root_file_path).should be_true
    BHLIndexer::Config.root_file_path = File.join(File.dirname(__FILE__), 'files/bhl_sample/')
  end
  
  before(:each) do
    ActiveRecord::Base.connection.execute("truncate table titles")
  end
  
  context "#populate" do
    it "should populate titles from root file path" do
      Title.count.should == 0
      Title.populate
      Title.count.should == 7
      files = Dir.entries(Title.first.path).select{|f| f.match /\.txt$/}
      files.size.should == 138
      files.first.should == 'journalofentomol13pomo_0001.txt'
    end
  end
end