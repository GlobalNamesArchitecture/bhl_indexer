# frozen_string_literal: true

ENV['RACK_ENV'] || 'development'
require './app.rb'

set :run, false

run BHLIndexer::App
