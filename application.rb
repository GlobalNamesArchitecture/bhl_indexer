#!/usr/bin/env ruby

require_relative './environment'

puts 'hello bhl indexer'

__END__

#!/usr/bin/env ruby

a = "hello world"

trap("SIGINT") { 
  puts 'finishing things'
  puts a
  throw :ctrl_c 
}

catch :ctrl_c do
  begin
    while 1 
      puts 'wwwooorking'
      sleep 2
    end
  rescue Exception
    puts 'doing ctrlc stuff'
  end
end
