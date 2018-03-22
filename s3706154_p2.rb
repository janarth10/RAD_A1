#!/usr/bin/env ruby

require 'nokogiri'
require 'optparse'

options = {}
begin
  OptionParser.new do |opt|
    opt.on("--xml [FILENAME]", "loads given filename, or uses first xml file in directory if flag not used") { |o|
      options[:xml_file] = o}
    opt.on("--name FIRST/LAST NAME", "Searches for emails with the given name") { |o| options[:name] = o}
    opt.on("--ip IP ADDRESS", "Searches for emails with the given ip address") { |o| options[:ip_addr] = o}
  end.parse!

  if options.has_key?(:xml_file)
    file_name = options[:xml_file]
  else
    # check for first xml file if not provided
    Dir.entries(".").each do |entry|
      if entry.to_s.chars.last(4).join == ".xml"
        file_name = entry.to_s
      end
    end
  end

  doc = Nokogiri::XML(open(file_name))
  nodes =  doc.xpath("//record")
  first_names = doc.xpath("//first_name")
  last_names = doc.xpath("//last_name")
  ip_addr_lst = doc.xpath("//ip_address")

  if options.has_key?(:name)
    i = 0
    nodes.size.times do
      if first_names[i].children.to_s.casecmp(options[:name]) != 0 and
          last_names[i].children.to_s.casecmp(options[:name]) != 0
        nodes.delete(nodes[i])
        first_names.delete(first_names[i])
        last_names.delete(last_names[i])
        ip_addr_lst.delete(ip_addr_lst[i])
      else
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
      else
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
    value = ""
    end_of_first_tag = str.index("/>")
    if end_of_first_tag.nil?
      end_of_first_tag = str.index(">")
      beg_of_second_tag = str.index("</")
      value = "#{str[end_of_first_tag+1..beg_of_second_tag-1]}"
    end
    tag = "\"#{str[1..end_of_first_tag-1]}\""

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

