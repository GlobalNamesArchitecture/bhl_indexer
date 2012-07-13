ENV['BHL_ENV'] = 'test'

require_relative '../environment.rb'
require 'rspec'
BHLIndexer::Config.root_file_path = File.join(File.dirname(__FILE__), 'files', 'bhl_sample')

def nuke_data
  Title.connection.execute("truncate table pages")
  Title.connection.execute("truncate table titles")
  Title.connection.execute("truncate table name_strings")
  Title.connection.execute("truncate table page_name_strings")
end


