#!/usr/bin/env ruby

require 'base64'
require 'optparse'
require 'pp'
require 'socket'

@options = {}
DEFAULT_PORT = 8080
CHUNK_SIZE = 4096

module Helpers
  # Define loggers
  def log_verbose(s)
    if @options[:verbose] == true
      puts s
    end
  end

  # Define authentication helper(s)
  def accept_auth(user, pass)
    [@options[:user], @options[:pass]] == [user, pass]
  end
end

include Helpers

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
    if p.to_i.to_s == p && p.to_i < 65536 && p.to_i > 0
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

# Require a file to serve
if ARGV.length != 1 && !(ARGV.length == 0 && @options[:serve_self] == true)
  $stderr.puts "No file specified and --serve-self option not passed; aborting"
  Kernel.exit
end
if @options[:serve_self] == true
  @options[:file_path] = "wos.rb"
else
  @options[:file_path] = ARGV[0]
end

class WOS
  def initialize(opts)
    @options = opts
  end

  def serve!
    log_verbose("Serving file #{File.size(@options[:file_path])} bytes large")
    
    # Open Web server
    serv = TCPServer.new(@options[:port])
    puts "Listening on port #{@options[:port]}"
    while s = serv.accept
      # Read HTTP request
      req = []
      while l = s.gets
        req.push l
        if l == "\r\n"
          break
        end
      end
      log_verbose("#{s.peeraddr[2]}: #{req[0]}")
      served = false
    
      # Fetch username/pass out of request
      user = nil
      pass = nil
      req.each do |r|
        if r[/^Authorization: Basic /] == "Authorization: Basic "
          auth_b64 = /^Authorization: Basic (.*)$/.match(r)[1]
          auth = Base64.decode64(auth_b64)
          user = auth.split(":")[0]
          pass = auth.split(":")[1]
          log_verbose("Credentials: #{user} : #{pass}")
        end
      end
      
      # Parse file from request; redirect if necessary
      req_file = req[0].split(" ")[1][1..-1]
      if accept_auth(user, pass)
        if req_file == File.basename(@options[:file_path])
          if !File.exist?(@options[:file_path])
            s.print "HTTP/1.1 404/Not Found"
          else
            s.print "HTTP/1.1 200/OK\r\n"
            s.print "Content-Length: #{File.size(@options[:file_path])}\r\n"
            s.print "\r\n"
            File.open(@options[:file_path]) do |f|
              while chunk = f.read(CHUNK_SIZE)
                s.print chunk
              end
            end
          end
          s.close
          break
        else
          s.print "HTTP/1.1 301/Moved Permanently\r\nLocation: #{File.basename(@options[:file_path])}\r\n\r\n"
        end
      else
        s.print "HTTP/1.1 401/Unauthorized\r\nWWW-Authenticate: basic\r\n\r\n"
      end
    end
  end
end

if __FILE__ == $0
  wos = WOS.new(@options).serve!
end
