# encoding: utf-8
require_relative "./spec_helper"

describe BHLIndexer::ResolverClient do
  before(:each) do
    nuke_data
    Title.populate
    @resolver = BHLIndexer::ResolverClient.new
    @carousel = BHLIndexer::Carousel.new
    @carousel.herd_size = 3
    @carousel.populate
    @carousel.send_texts
    until @carousel.carousel_ary.empty?
      sleep(5)
      @carousel.get_names
    end
  end

  it "should get information about names from resolver" do
    @resolver.process_batch
  end
end
