#!/usr/bin/env ruby

require 'nokogiri'
require 'optparse'
require 'date'

options = {}
begin
  OptionParser.new do |opt|
    opt.on("--xml [FILENAME]", "loads given filename, or uses first xml file in directory if flag not used") { |o|
      options[:xml_file] = o}
    opt.on("--name FIRST/LAST NAME", "Searches for emails with the given name") { |o| options[:name] = o}
    opt.on("--ip IP ADDRESS", "Searches for emails with the given ip address") { |o| options[:ip_addr] = o}
    opt.on("--before DATE", "Searches for emails before given date") { |o| options[:before] = Date.new(*o.split("-").map{ |s| s.to_i }) }
    opt.on("--after DATE", "Searches for emails after given date") { |o| options[:after] = Date.new(*o.split("-").map{ |s| s.to_i }) }
    opt.on("--day DAY", "Searches for emails on given day") { |o| options[:day] = o}
  end.parse!

  if options.has_key?(:before) and options.has_key?(:after) and (options[:before] <=> options[:after]) == -1
    raise "Invalid input: \"before\" date must not be earlier than \"after\" date"
  end

  if options.has_key?(:xml_file)
    file_name = options[:xml_file]
  elsif
    # check for first xml file if not provided
    Dir.entries(".").each do |entry|
      if entry.to_s.chars.last(4).join == ".xml"
        file_name = entry.to_s
      end
    end
  end

  doc = Nokogiri::XML(open(file_name))
  nodes =  doc.xpath("//record")
  nodes = nodes[0..3]
  first_names = doc.xpath("//first_name")
  last_names = doc.xpath("//last_name")
  ip_addr_lst = doc.xpath("//ip_address")

  # filtering records
  if options.has_key?(:name)
    i = 0
    nodes.size.times do
      if first_names[i].children.to_s.casecmp(options[:name]) != 0 and
          last_names[i].children.to_s.casecmp(options[:name]) != 0
        nodes.delete(nodes[i])
        first_names.delete(first_names[i])
        last_names.delete(last_names[i])
        ip_addr_lst.delete(ip_addr_lst[i])
      elsif
        i += 1
      end
    end
  end

  if options.has_key?(:ip_addr)
    i = 0
    nodes.size.times do
      if ip_addr_lst[i].children.to_s.casecmp(options[:ip_addr]) != 0
        nodes.delete(nodes[i])
        first_names.delete(first_names[i])
        last_names.delete(last_names[i])
        ip_addr_lst.delete(ip_addr_lst[i])
      elsif
      i += 1
      end
    end
  end

  # input: nodeset of Nokogiri::XML::Element
  def puts_xml_to_json(arr)
    arr.each do |elem|
      str = elem.to_s
      tag, val = extract_tag_and_value(str)
      if elem == arr.first
        puts "{ #{tag}: #{val},"
      elsif elem == arr.last
        puts "#{tag}: #{val}\n},"
      else
        puts "#{tag}: #{val},"
      end
    end
  end

  def extract_tag_and_value(str)
    end_of_first_tag = str.index(">")
    beg_of_second_tag = str.index("</")

    tag = "\"#{str[1..end_of_first_tag-1]}\""
    value = "#{str[end_of_first_tag+1..beg_of_second_tag-1]}"
    if tag != "\"id\""
      value = "\"#{value}\""
    end
    return tag, value
  end

  nodes.each do |elem|
    puts_xml_to_json(elem.children)
  end

rescue StandardError => e
  puts e.message
end
