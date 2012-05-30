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

  it "should initialize" do
    Title.populate
    title = Title.all[1]
    title.should_not be_nil
    title.concatenated_text[0..10].should == "\r\r\nBound at"
    title.pages_offsets.first.should == 3
    title.pages_ids.first.should == 'journalofentomol14pomo_0001'
    title.gnrd_url.should be_nil
  end

  it "should send request to gnrd, and get intermediate and final response" do
    Title.populate
    title = Title.first
    title.gnrd_url.should be_nil
    title.send_text
    title.gnrd_url.match(BHLIndexer::Config.gnrd_api_url).should be_true
    title.get_names
    title.names.should == nil
    success = false
    while !success do 
      sleep(10)
      title.get_names
      next unless title.names
      title.names.class.should == Array
      title.names.first.should == {:verbatim=>"Arachnida", :scientificName=>"Arachnida", :offsetStart=>698, :offsetEnd=>706}
      title.make_pages
      success = true
    end
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
