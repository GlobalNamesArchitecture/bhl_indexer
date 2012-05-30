# encoding: utf-8
require_relative "./spec_helper"

describe BHLIndexer::GnrdClient do 
  it "should initialize" do 
    @client = BHLIndexer::GnrdClient.new(BHLIndexer::Config.gnrd_api_url, BHLIndexer::Config.gnrd_batch_size)
    @client.should_not be_nil
  end

  # it "should query GNRD and send results into database" do
  #   @client.find_names
  #   require 'ruby-debug'; debugger
  #   puts ''
  # end

end
