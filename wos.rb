#!/usr/bin/env ruby

require 'optparse'
require 'pp'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: wos.rb [options]"

  opts.on("-v", "--[no-]verbose", "Be verbose") do |v|
    options[:verbose] = v
  end
end.parse!

pp options
pp ARGV
