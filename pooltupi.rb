#!/usr/bin/ruby

require 'net/http'
require 'json'
# require 'open-uri'

uri = URI('https://pooltupi.com/api/pool/blocks/pplns')

response = Net::HTTP.get(uri)
json = JSON.parse(response)

json.each do |hashs|
  hashs.each do |key1, value1|
    puts "#{key1} - #{value1}"
  end
  puts "\n"
end
