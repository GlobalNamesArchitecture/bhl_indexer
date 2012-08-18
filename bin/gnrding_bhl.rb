#!/usr/bin/env ruby
require 'pp'
# encoding: utf-8

#use BHL_ENV to setup the environment: BHL_ENV=test ./gnrding_bhl.rb

require_relative '../environment.rb'
a = 'huh?'
until ['y','n','yes','no','yeah','nah'].include?(a)
  puts 'Do you want to truncate previous results? y/n'
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
carousel.herd_size = 10
carousel.rebuild_names_hash
carousel.populate
until carousel.carousel_ary.empty?
  pp carousel.carousel_ary
  carousel.send_texts
  sleep(5)
  carousel.get_names
  carousel.populate
end


