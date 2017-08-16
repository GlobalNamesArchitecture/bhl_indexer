#!/usr/bin/env ruby

require_relative './environment'
require 'sinatra'
require 'json'

module BHLIndexer
  # Placeholder for API interface
  class App < Sinatra::Application
    get '/' do
      content_type :json
      'hello'.to_json
    end
  end
end
