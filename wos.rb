#!/usr/bin/env ruby

require 'optparse'
require 'pp'

options = {}
DEFAULT_PORT = 8080

# Parse arguments
OptionParser.new do |opts|
  opts.banner = "Usage: wos.rb [options]"

  opts.on("-v", "--verbose", "Be verbose") do |v|
    options[:verbose] = v
  end

  opts.on("-s", "--serve-self", "Serve the wos.rb script file") do |s|
    options[:serve_self] = s
  end

  options[:port] = DEFAULT_PORT
  opts.on("-p", "--port [PORT]", "Use a specific port") do |p|
    if p.to_i.to_s == p && p.to_i < 65536 && p.to_i > 0:
      options[:port] = p.to_i
    else
      options[:port] = DEFAULT_PORT
    end
  end

  opts.on("-U", "--user [USER]", "Require user for authentication") do |u|
    options[:user] = u
  end

  opts.on("-P", "--pass [PASSWORD]", "Require password for authentication") do |p|
    options[:pass] = p
  end
end.parse!

pp options
pp ARGV

# Require a file to serve
if ARGV.length != 1 && !(ARGV.length == 0 && options[:serve_self] == true)
  $stderr.puts "No file specified and --serve-self option not passed; aborting"
end
