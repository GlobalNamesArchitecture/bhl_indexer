# encoding: utf-8
require_relative "./spec_helper"

describe Title do
  before(:all) do
    BHLIndexer::Config.respond_to?(:root_file_path).should be_true
    BHLIndexer::Config.root_file_path = File.join(File.dirname(__FILE__), 'files/bhl_sample/')
  end

  before(:each) do
    nuke_data
  end

  it "should initialize" do
    Title.populate
    title = Title.all[1]
    title.should_not be_nil
    title.language.should == 'English'
    title.concatenated_text[0..10].should == "\r\r\nBound at"
    title.pages_offsets.first.should == 3
    title.pages_ids.first.should == 'journalofentomol14pomo_0001'
    title.gnrd_url.should be_nil
    title.pages.count.should == 0
    title.create_pages
    title.pages.count.should > 0
    title.pages.first.id.should == 'journalofentomol14pomo_0001'
  end

  it "should send request to gnrd, and get intermediate and final response" do
    Title.populate
    title = Title.first
    title.language.should == 'English'
    title.create_pages
    title.gnrd_url.should be_nil
    title.send_text
    title.status.should == Title::STATUS[:sent]
    title.gnrd_url.match(BHLIndexer::Config.gnrd_api_url).should be_true
    success = false
    while !success do 
      sleep(10)
      title.get_names
      title.status.should == Title::STATUS[:sent]
      next unless title.names
      title.names.class.should == Array
      title.names.first.should == {:verbatim=>"Arachnida.", :scientificName=>"Arachnida", :offsetStart=>698, :offsetEnd=>707, :identifiedName=>"Arachnida"}
      title.names_to_pages
      title.pages[7].name_strings.should_not be_nil
      bad_offsets = PageNameString.all.select do |n| 
        offset_average = (n.name_offset_start + n.name_offset_end)/2
        offset_average < 0 || offset_average > 3000
      end
      bad_offsets.size.should == 0
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
