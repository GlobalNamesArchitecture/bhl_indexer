# encoding: utf-8
require_relative "./spec_helper"

describe BHLIndexer::Worker do 
  it "should initialize" do 
    @worker = BHLIndexer::Worker.new(BHLIndexer::Config.gnrd_api_url, BHLIndexer::Config.gnrd_batch_size)
    @worker.should_not be_null
  end
end
