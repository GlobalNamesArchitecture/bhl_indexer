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

  it "should normalize names" do
    NameString.normalize("(A)").should be_nil
    NameString.normalize("(AO)").should == "Ao"
    NameString.normalize("PArdØsa").should == "Pardøsa"
    NameString.normalize("(PARDOSA").should == "Pardosa"
    NameString.normalize("Pardosa").should == "Pardosa"
    NameString.normalize("Pardosa Moesta").should == "Pardosa moesta"
    NameString.normalize("PardOSa (PARDOSA) moesta").should == "Pardosa (Pardosa) moesta"
    NameString.normalize("Pardosa (moesta").should == "Pardosa (Moesta)"
    NameString.normalize("Pardosa (pardosa) Moesta").should == "Pardosa (Pardosa) moesta"
    NameString.normalize("Pardosa Moesta F. vulgarÎs").should == "Pardosa moesta f. vulgarîs"
    NameString.normalize("Pardosa Moesta quercus quercus quercus Quercus").should == "Pardosa moesta quercus quercus quercus quercus"
  end

end

