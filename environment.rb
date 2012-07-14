require 'bundler'
require 'ostruct'
require 'logger'
require 'mysql2'
require 'active_record'
require 'composite_primary_keys'
require 'rest_client'
require 'json'
require 'find'
require 'unicode_utils'

module BHLIndexer
  
  def self.symbolize_keys(obj)
    if obj.class == Array
      obj.map {|o| BHLIndexer.symbolize_keys(o)}
    elsif obj.class == Hash
      obj.inject({}) {|res, data| res.merge(data[0].to_sym => BHLIndexer.symbolize_keys(data[1]))}
    else
      obj
    end
  end

  root_path = File.expand_path(File.dirname(__FILE__))
  CONF_DATA = BHLIndexer.symbolize_keys(YAML.load(open(File.join(root_path, 'config.yml')).read))
  conf = CONF_DATA
  environment = ENV['BHL_ENV'] || 'development'
  Config = OpenStruct.new(
                 :gnrd_api_url => conf[:gnrd_api_url],
                 :root_path => root_path,
                 :root_file_path => conf[:root_file_path],
                 :environment => environment,
                 :carousel_size => conf[:carousel_size]
               )
  # load models
  db_settings = conf[Config.environment.to_sym]
  ActiveRecord::Base.logger = Logger.new(STDOUT, :debug)
  ActiveRecord::Base.establish_connection(db_settings)
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib', 'bhl_indexer'))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
  Dir.glob(File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')) { |lib|   require File.basename(lib, '.*') }
  Dir.glob(File.join(File.dirname(__FILE__), 'models', '*.rb')) { |model| require File.basename(model, '.*') }
end

