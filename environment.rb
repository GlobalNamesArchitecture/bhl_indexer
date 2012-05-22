require 'bundler'
require 'ostruct'
require 'logger'
require 'mysql2'
require 'active_record'
require 'rest_client'
require 'json'

module BHLIndexer
  root_path = File.expand_path(File.dirname(__FILE__))
  conf = YAML.load(open(File.join(root_path, 'config.yml')).read)
  environment = conf['environment'] || 'development'
  db_settings = conf[environment]
  Config = OpenStruct.new(
                 :gnrd_api_url => conf['gnrd_api_url'],
                 :root_path => root_path,
               )
  # load models
  # ActiveRecord::Base.logger = Logger.new(STDOUT, :debug)
  # ActiveRecord::Base.establish_connection(conf)
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib', 'bhl_indexer'))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
  Dir.glob(File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')) { |lib|   require File.basename(lib, '.*') }
  Dir.glob(File.join(File.dirname(__FILE__), 'models', '*.rb')) { |model| require File.basename(model, '.*') }
end
