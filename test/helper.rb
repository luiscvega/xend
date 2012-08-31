require 'json'
require "cutest"
require_relative "../lib/xend"

ZIPCODES = JSON.parse(File.read(File.join(File.expand_path("../zipcodes", File.dirname(__FILE__)), "zipcodes.json")))

raise ZIPCODES["Abra"][0].inspect
