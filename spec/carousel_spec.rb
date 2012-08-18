# encoding: utf-8
require_relative "./spec_helper"

describe BHLIndexer::Carousel do
  before(:each) do
    nuke_data
    Title.populate
    @carousel = BHLIndexer::Carousel.new
    @carousel.herd_size = 2
    @carousel.rebuild_names_hash
    @carousel.should_not be_nil
  end

  it "empty carousel should get populated with concatenated texts" do
    @carousel.populate
    @carousel.size.should == @carousel.herd_size
    item = @carousel.carousel_ary[1]
    item.class.should == Title 
    item.concatenated_text[0..10].should == "\r\r\nBound at"
    item.pages_offsets.last.should == 169000
    item.pages_ids.last.should == 'journalofentomol14pomo_0114'
    item.pages_offsets.size.should == item.pages_ids.size
  end

  it "should get names from gnrd from all titles in the herd" do
    @carousel.populate
    until @carousel.carousel_ary.empty?
      pp @carousel.carousel_ary
      @carousel.send_texts
      sleep(5)
      @carousel.get_names
      @carousel.populate
    end
    @carousel.size.should < @carousel.herd_size
  end
end

