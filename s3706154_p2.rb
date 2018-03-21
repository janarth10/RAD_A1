#!/usr/bin/env ruby

require 'nokogiri'

std_num="s3706154_p2.rb"

puts "Commands:"
puts "#{std_num} -xml [filename]   # Load a XML file"
puts "#{std_num} help [COMMAND]    # Describe available commands or one specific command"

command = gets.chomp.split(" ")
if command.size == 3 and command[0] == std_num and command[1] == "-xml"
	puts "xml option"
        doc = Nokogiri::XML(File.open(command[2]))
	doc.xpath("//record").each do |i|
		puts i
	end
elsif command.size == 2 and command[0] == std_num and command[1] == "help"
	puts "help"
elsif command.size == 3 and command[0] == std_num and command[1] == "help"
        puts "specific help"
else
	puts "invalid command"
end
