ENV['BHL_ENV'] = 'test'

require_relative '../environment.rb'
require 'rspec'
BHLIndexer::Config.root_file_path = File.join(File.dirname(__FILE__), 'files', 'bhl_sample')

def nuke_data
  Title.connection.execute("truncate table pages")
  Title.connection.execute("truncate table titles")
  Title.connection.execute("truncate table name_strings")
  Title.connection.execute("truncate table page_name_strings")
  Title.connection.execute("truncate table resolved_canonical_forms")
  Title.connection.execute("truncate table resolved_name_strings")
end

RSpec.configure do |config|
  config.before(:suite) do
    Title.connection.execute("truncate table languages")
    sql = "LOAD DATA INFILE '#{File.join(BHLIndexer::Config.root_path, 'db', 'BHLItemLanguage.csv')}' INTO TABLE languages FIELDS TERMINATED BY ',' LINES TERMINATED BY '\r\n' (internet_archive_id, name)"
    ActiveRecord::Base.connection.execute sql
  end

  config.after(:suite) do
    Title.connection.execute("truncate table languages")
  end
end


