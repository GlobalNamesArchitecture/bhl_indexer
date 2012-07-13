# encoding: utf-8
require_relative "./spec_helper"

describe NameString do
  
  before(:each) do 
    nuke_data
  end

  it "should initialize" do
    ns = NameString.create(:name => "Pomatomus saltator")
    ns.should_not be_nil
  end

end

