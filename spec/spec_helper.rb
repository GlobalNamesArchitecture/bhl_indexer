ENV['BHL_ENV'] = 'test'

require_relative '../environment.rb'
require 'rspec'
BHLIndexer::Config.root_file_path = File.join(File.dirname(__FILE__), 'files', 'bhl_sample')


