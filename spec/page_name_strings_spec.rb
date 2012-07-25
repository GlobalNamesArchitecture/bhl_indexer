# encoding: utf-8
require_relative "./spec_helper"

describe PageNameString do

  before(:each) do 
    nuke_data
  end
  
  it "should initialize" do 
    Title.populate
    ns = NameString.create(:name => "Betula uglia")
    book = Title.first
    book.create_pages
    pns = PageNameString.create(:name_string_id => ns.id, :page_id => book.pages.first.id, :name_offset_start => 5, :name_offset_end => 12)
    pns.should_not be_nil
    book.pages.first.name_strings.size.should == 1
    book.pages.first.id.should == "journalofentomol13pomo_0001"
  end
end
