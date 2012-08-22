#!/usr/bin/env ruby
require_relative '../environment.rb'

puts 'Starting to populate titles'
Title.connection.execute("truncate table pages")
Title.connection.execute("truncate table titles")
Title.connection.execute("truncate table name_strings")
Title.connection.execute("truncate table page_name_strings")
Title.connection.execute("truncate table resolved_canonical_forms")
Title.connection.execute("truncate table resolved_name_strings")
Title.connection.execute("truncate table languages")
puts 'Getting all languages'
Language.populate
puts 'Got all languages'
Title.populate
puts 'Done populating titles'
