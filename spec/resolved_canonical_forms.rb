# encoding: utf-8
require_relative "./spec_helper"

describe ResolvedCanonicalForm do

  before(:each) do 
    nuke_data
  end
  
  it "should initialize" do
    cf = ResolvedCanonicalForm.create(:name => "Pomatomus saltator")
    cf.should_not be_nil
  end

end

