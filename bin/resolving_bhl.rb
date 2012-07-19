#!/usr/bin/env ruby
# encoding: utf-8

#use BHL_ENV to setup the environment: BHL_ENV=test ./resolving_bhl.rb

require_relative '../environment.rb'
resolver = BHLIndexer::ResolverClient.new
# rows_num = 1
# until rows_num == 0
#   rows_num = resolver.process_batch
# end

rows_num = 1
until rows_num == 0
  rows_num = resolver.process_failed_batches(2)
end


