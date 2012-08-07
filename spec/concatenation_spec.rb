# encoding: utf-8
require_relative "./spec_helper"

describe "Concatenator" do 
  before(:all) do
    @pages_path = File.join(File.dirname(__FILE__), 'files/bhl_sample/bhl1/01108casxa2200325xax4500/journalofentomol13pomo')
    @concatenator = BHLIndexer::Concatenator.new(@pages_path)
  end

  it "should have list of all files to concatenate" do
    @concatenator.files.size.should == 138
  end

  it "should concatenate files remembering where each of them starts and ends" do
    @concatenator.concatenate
    @concatenator.concatenated_text.size.should == 189687
    @concatenator.pages_offsets.class.should == Array
    @concatenator.pages_ids.class.should == Array
    @concatenator.pages_offsets.should == [0, 0, 0, 0, 0, 0, 226, 1501, 2321, 2321, 3212, 5869, 8305, 8901, 9270, 11066, 11222, 11642, 12190, 12190, 15150, 16916, 18531, 21599, 23318, 26303, 29421, 32531, 35528, 38615, 40417, 43483, 45913, 48339, 50110, 52615, 55003, 57233, 59456, 59456, 60116, 60944, 62001, 62328, 62937, 66134, 68519, 68519, 68519, 71340, 71798, 74810, 76450, 79624, 81144, 84266, 85847, 88463, 89886, 92570, 95393, 98121, 100802, 102944, 104581, 105960, 106141, 106277, 108812, 110443, 111824, 112042, 112658, 113144, 113848, 114242, 115169, 115638, 116628, 117020, 117254, 119747, 120290, 120290, 123276, 124999, 126177, 129164, 131367, 133542, 133542, 133542, 135618, 137708, 139944, 141960, 144071, 146155, 148954, 151415, 153958, 156319, 157105, 157105, 160138, 160481, 161841, 163290, 166317, 169236, 172250, 173622, 175876, 178070, 178526, 178526, 179261, 181409, 181409, 181409, 182067, 184216, 184216, 184216, 184779, 186927, 186927, 186927, 187539, 189687, 189687, 189687, 189687, 189687, 189687, 189687, 189687, 189687]
    @concatenator.pages_ids.first.should == 'journalofentomol13pomo_0001'
  end

  it "should have the same offsets count as TaxonFinder" do
    @concatenator.concatenate
    res = RestClient.post(BHLIndexer::Config.gnrd_api_url, :text => @concatenator.concatenated_text, :engine => 1, :unique => false)
    url = JSON.parse(res, :symbolize_names => true)[:token_url]
    sleep(20)
    names = JSON.parse(RestClient.get(url), :symbolize_names => true)[:names]
    @concatenator.concatenated_text[names.last[:offsetStart]..names.last[:offsetEnd]].should == names.last[:verbatim]
  end
  
  it "should have the same offsets count as NetiNeti" do
    res = RestClient.post(BHLIndexer::Config.gnrd_api_url, :text => @concatenator.concatenated_text, :engine => 2, :unique => false)
    url = JSON.parse(res, :symbolize_names => true)[:token_url]
    sleep(20)
    names = JSON.parse(RestClient.get(url), :symbolize_names => true)[:names]
    @concatenator.concatenated_text[names.last[:offsetStart]..names.last[:offsetEnd]].should == names.last[:verbatim]
  end

end
