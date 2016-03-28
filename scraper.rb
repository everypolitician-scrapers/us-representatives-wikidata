#!/bin/env ruby
# encoding: utf-8

require 'json'
require 'pry'
require 'rest-client'
require 'scraperwiki'
require 'wikidata/fetcher'
require 'mediawiki_api'
require 'active_support/inflector'

def members
  morph_api_url = 'https://api.morph.io/tmtmtmtm/us-congress-members/data.json'
  morph_api_key = ENV["MORPH_API_KEY"]
  result = RestClient.get morph_api_url, params: {
    key: morph_api_key,
    query: "select DISTINCT(identifier__wikipedia) AS wikiname from data WHERE house = 'rep'"
  }
  JSON.parse(result, symbolize_names: true)
end


names = {}
(97 .. 114).each do |cid|
  puts cid
  names[cid] = EveryPolitician::Wikidata.wikipedia_xpath( 
    url: "https://en.wikipedia.org/wiki/#{ActiveSupport::Inflector.ordinalize cid}_United_States_Congress",
    after: '//span[@id="House_of_Representatives_3"]',
    before: '//span[@id="Changes_in_membership"]',
    xpath: './/li//a[not(@class="new")]/@title',
  ).reject { |n| n.downcase.include? 'congressional district' }
end

morph_names = members.map { |w| w[:wikiname] }
wiki_names = names.values.flatten.uniq

EveryPolitician::Wikidata.scrape_wikidata(names: { en: morph_names | wiki_names }, batch_size: 50)
