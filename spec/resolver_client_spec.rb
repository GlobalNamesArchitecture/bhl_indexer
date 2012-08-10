# encoding: utf-8
require_relative "./spec_helper"

describe BHLIndexer::ResolverClient do
  before(:each) do
    nuke_data
    Title.populate
    @resolver = BHLIndexer::ResolverClient.new
    @carousel = BHLIndexer::Carousel.new
    @carousel.herd_size = 4
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
    @resolver.process_batch
    ResolvedCanonicalForm.count.should > 500
    ResolvedNameString.count.should > 1000
  end

  # it "should be able to process files which failed first time" do
  #   @resolver.process_failed_batches
  # end
end
