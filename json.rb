#!/usr/bin/ruby

require 'json'
require 'net/http'

url = open('https%3A%2F%2Fmin-api.cryptocompare.com%2Fdata%2Fpricemulti%3Ffsyms%3DBTC%2CDASH%2CXMR%2CLTC%2CAEON%2CIOTA%26tsyms%3DUSD%2CBRL')
uri = URI(url)
response = NET::HTTP.get(uri)
parsed = JSON.parse(response)
puts parsed

#puts btcusd = parsed["BTC"]["USD"]
#puts btcbrl = parsed["BTC"]["BRL"]
