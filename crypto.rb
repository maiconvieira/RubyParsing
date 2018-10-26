#!/usr/bin/ruby

require 'net/http'
require 'json'
# require 'open-uri'

uri = URI('https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,DASH,XMR,AEON,IOTA&tsyms=BTC,USD,BRL')

response = Net::HTTP.get(uri)
json = JSON.parse(response)

json.each do |key, value|
  value.each { |key1, value1| puts "#{key}: #{key1} - #{value1}" }
end
