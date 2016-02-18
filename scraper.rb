#!/bin/env ruby
# encoding: utf-8

require 'json'
require 'pry'
require 'rest-client'
require 'scraperwiki'
require 'wikidata/fetcher'
require 'mediawiki_api'

def members
  morph_api_url = 'https://api.morph.io/tmtmtmtm/us-congress-members/data.json'
  morph_api_key = ENV["MORPH_API_KEY"]
  result = RestClient.get morph_api_url, params: {
    key: morph_api_key,
    query: "select DISTINCT(identifier__wikipedia) AS wikiname from data WHERE house = 'rep'"
  }
  JSON.parse(result, symbolize_names: true)
end

members.map { |w| w[:wikiname] }.each_slice(250) do |sliced|
  EveryPolitician::Wikidata.scrape_wikidata(names: { en: sliced })
end
warn EveryPolitician::Wikidata.notify_rebuilder
