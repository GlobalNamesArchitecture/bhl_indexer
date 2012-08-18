#!/usr/bin/env ruby
# encoding: utf-8

#use BHL_ENV to setup the environment: BHL_ENV=test ./resolving_bhl.rb

require_relative '../environment.rb'

a = 'huh?'
q = "\nDo you REALLY want to truncate %s resolved name strings? y/n" % ResolvedNameString.count.to_s

until ['y','n','yes','no','yeah','nah'].include?(a)
  puts q
  a = gets.strip
end

if ['yes','y','yeah'].include?(a)
  Title.connection.execute("truncate table resolved_canonical_forms")
  Title.connection.execute("truncate table resolved_name_strings")
  Title.connection.execute("update name_strings set status = 0")
end

resolver = BHLIndexer::ResolverClient.new
resolver.rebuild_resolved_names_hash

rows_num = 1
until rows_num == 0
  rows_num = resolver.process_failed_batches(50)
end


