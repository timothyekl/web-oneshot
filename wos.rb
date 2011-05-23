#!/usr/bin/env ruby

require 'optparse'
require 'pp'
require 'socket'

@options = {}
DEFAULT_PORT = 8080

# Parse arguments
OptionParser.new do |opts|
  opts.banner = "Usage: wos.rb [options]"

  opts.on("-v", "--verbose", "Be verbose") do |v|
    @options[:verbose] = v
  end

  opts.on("-s", "--serve-self", "Serve the wos.rb script file") do |s|
    @options[:serve_self] = s
  end

  @options[:port] = DEFAULT_PORT
  opts.on("-p", "--port [PORT]", "Use a specific port") do |p|
    if p.to_i.to_s == p && p.to_i < 65536 && p.to_i > 0:
      @options[:port] = p.to_i
    end
  end

  opts.on("-U", "--user [USER]", "Require user for authentication") do |u|
    @options[:user] = u
  end

  opts.on("-P", "--pass [PASSWORD]", "Require password for authentication") do |p|
    @options[:pass] = p
  end
end.parse!

# Define loggers
def log_verbose(s)
  if @options[:verbose] == true
    puts s
  end
end

# Require a file to serve
if ARGV.length != 1 && !(ARGV.length == 0 && @options[:serve_self] == true)
  $stderr.puts "No file specified and --serve-self option not passed; aborting"
end
if @options[:serve_self] == true
  file = "wos.rb"
else
  file = ARGV[0]
end

# Read file into memory
contents = open(file, "rb") { |f| f.read }
log_verbose("Opened file #{file}")
log_verbose("Read #{contents.length} bytes")

# Open Web server
serv = TCPServer.new(@options[:port])
log_verbose("Listening on port #{@options[:port]}")
while s = serv.accept
  req = s.gets
  log_verbose("#{s.peeraddr[2]}: #{req}")
  served = false
  
  # Parse file from request; redirect if necessary
  req_file = req.split(" ")[1][1..-1]
  if req_file == File.basename(file)
    s.print "HTTP/1.1 200/OK\r\n\r\n" + contents
    s.close
    served = true
  else
    s.print "HTTP/1.1 301/Moved Permanently\r\nLocation: #{File.basename(file)}\r\n\r\n"
  end

  if served
    break
  end
end
