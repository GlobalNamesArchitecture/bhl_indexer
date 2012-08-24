# encoding: utf-8
require_relative "./spec_helper"

describe BHLIndexer::ResolverClient do
  before(:each) do
    nuke_data
    Title.populate
    @resolver = BHLIndexer::ResolverClient.new
    @resolver.batch_size = 25
    @carousel = BHLIndexer::Carousel.new
    @carousel.herd_size = 3
    @carousel.rebuild_names_hash
    @carousel.populate
    @carousel.send_texts
    until @carousel.carousel_ary.empty?
      sleep(5)
      @carousel.get_names
    end
  end

  it "should get information about names from resolver" do
    ResolvedCanonicalForm.count.should == 0
    ResolvedNameString.count.should == 0
    processed = @resolver.process_batch
    @resolver.batch_size.should == processed
    ResolvedCanonicalForm.count.should > 10
    ResolvedNameString.count.should > 20
  end

end
