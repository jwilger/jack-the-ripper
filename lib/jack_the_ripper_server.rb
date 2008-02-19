#!/usr/bin/env ruby
unless ENV[ 'AWS_ACCESS_KEY_ID' ] && ENV[ 'AWS_SECRET_ACCESS_KEY' ]
  raise "Must set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY first!"
end
Signal.trap( "INT" ) { shutdown() }
Signal.trap( "TERM" ) { shutdown() }

@keep_running = true
def shutdown
  @logger.info "Starting System Shutdown"
  @keep_running = false
end

$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../lib' ) )
require 'jack_the_ripper'
require 'optparse'
require 'ostruct'

options = OpenStruct.new
options.access_key_id = ENV[ 'AWS_ACCESS_KEY_ID' ]
options.secret_access_key = ENV[ 'AWS_SECRET_ACCESS_KEY' ]
options.queue_name = ''
options.tmp_path = '/tmp'
options.log_file = '/var/log/jack_the_ripper.log'

opts = OptionParser.new do |opts|
  opts.banner = "Usage: jack_the_ripper_server [options]"
  opts.separator ""
  opts.separator "Specific options:"
    
  opts.on( '-q', '--queue SQS_QUEUE_NAME', 'REQUIRED' ) do |queue_name|
    options.queue_name = queue_name
  end
  
  opts.on( '-t', '--tmpdir [PATH]', 'Path to save temporary image files. Defaults to "/tmp"' ) do |tmp_path|
    options.tmp_path = tmp_path
  end
  
  opts.on( '-l', '--log [PATH]', 'Path to the log file. Defaults to "/var/log/jack_The_ripper.log"' ) do |log_file|
    options.log_file = log_file
  end
  
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end
opts.parse!( ARGV )

@logger = Logger.new( options.log_file )
@logger.level = Logger::WARN
JackTheRIPper.tmp_path = options.tmp_path
JackTheRIPper.logger = @logger
queue = JackTheRIPper.get_queue( options.access_key_id,
  options.secret_access_key, options.queue_name )
@logger.info "Connected to SQS Queue #{queue.name}"
begin
  while @keep_running do
    if JackTheRIPper.process_next_message( queue ) == false
      @logger.debug "No messages in queue. Sleeping for 60 seconds"
      60.times { sleep( 1 ) if @keep_running }
    end
  end
  exit 0
rescue SystemExit
  @logger.info "Shutdown Complete"
  exit 0
rescue Exception => e
  JackTheRIPper.logger.fatal e.class.to_s + ': ' + e.message
  JackTheRIPper.logger.fatal e.backtrace.join( "\n" )
  exit 1
end