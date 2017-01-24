require 'awesome_print'
require 'erb'
require 'mechanize'
require 'nokogiri'
require 'pry-byebug'
require File.join(File.dirname(__FILE__), 'hikaku/page_fetcher')
require File.join(File.dirname(__FILE__), 'hikaku/app_fetcher')
require File.join(File.dirname(__FILE__), 'hikaku/prototype_fetcher')
require File.join(File.dirname(__FILE__), 'hikaku/comparator')

module Hikaku
  NOT_IMPLEMENTED_YET = 'not_implemented_yet'
end

