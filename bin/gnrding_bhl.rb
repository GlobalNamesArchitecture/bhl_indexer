#!/usr/bin/env ruby
require 'pp'
# encoding: utf-8

#use BHL_ENV to setup the environment: BHL_ENV=test ./gnrding_bhl.rb

require_relative '../environment.rb'
a = 'huh?'
q = "\nDo you REALLY want to truncate %s namestrings and %s resolved name strings? y/n" % [NameString.count.to_s, ResolvedNameString.count.to_s]

until ['y','n','yes','no','yeah','nah'].include?(a)
  puts q
  a = gets.strip
end

if ['yes','y','yeah'].include?(a)
  Title.connection.execute("truncate table pages")
  Title.connection.execute("truncate table titles")
  Title.connection.execute("truncate table name_strings")
  Title.connection.execute("truncate table page_name_strings")
  Title.connection.execute("truncate table resolved_canonical_forms")
  Title.connection.execute("truncate table resolved_name_strings")
  Title.connection.execute("truncate table languages")
  Language.populate
  Title.populate
end

carousel = BHLIndexer::Carousel.new
carousel.rebuild_names_hash
carousel.populate
until carousel.carousel_ary.empty?
  pp carousel.carousel_ary
  carousel.send_texts
  sleep(5)
  carousel.get_names
  carousel.populate
end


