# encoding: utf-8
require_relative "./spec_helper"

describe ResolvedNameString do
  
  before(:each) do 
    nuke_data
    @ns = NameString.create(:name => "Pomatomus saltator")
    @cf = ResolvedCanonicalForm.create(:name => "Pomatomus saltator")
  end

  it "should initialize" do
    rns = ResolvedNameString.create(:name_string_id => @ns.id, :canonical_form_id => @cf.id, :name => "Pomatomus saltator", :gni_id => 59740382246565806402458658161816002818, :data_source_id => 169, :local_id => 2499763)
    rns.should_not be_nil
  end

end


