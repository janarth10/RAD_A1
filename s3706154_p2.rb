#!/usr/bin/env ruby

require 'nokogiri'
require 'optparse'

options = {}
OptionParser.new do |opt|
	opt.on("--xml [FILENAME]", "loads given filename, or uses first xml file in directory if flag not used") { |o|
		options[:xml_file] = o}
	opt.on("--name FIRST/LAST NAME", "Searches for emails with the given name") { |o| options[:name] = o}
  opt.on("--ip IP ADDRESS", "Searches for email with the given ip address") { |o| options[:ip_addr] = o}
end.parse!


