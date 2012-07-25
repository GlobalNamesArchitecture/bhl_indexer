# encoding: utf-8
require_relative "./spec_helper"

describe Page do

  before(:each) do
    nuke_data
  end
  
  it "should be able to create pages" do
    Title.populate
    t = Title.first
    t.create_pages
    t.pages.size.should > 0
    ns = NameString.create(:name => "Plantago major")
    PageNameString.create(:page_id => t.pages.first.id, :name_string_id => ns.id, :name_offset_start => 23, :name_offset_end => 44)
    t.pages.first.name_strings.size.should > 0
    t.pages.first.page_name_strings.size.should > 0
    t.pages.first.name_strings.first.name.should == 'Plantago major'
  end
end
