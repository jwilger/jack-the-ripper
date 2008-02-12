#!/usr/bin/env ruby
Signal.trap( "INT" ) { shutdown() }
Signal.trap( "TERM" ) { shutdown() }

@keep_running = true
def shutdown
  @keep_running = false
end

$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../lib' ) )
require 'jack_the_ripper'
require 'optparse'
require 'ostruct'

options = OpenStruct.new
options.access_key_id = ''
options.secret_access_key = ''
options.queue_name = ''
options.tmp_path = '/tmp'

opts = OptionParser.new do |opts|
  opts.banner = "Usage: jack_the_ripper_server [options]"
  opts.separator ""
  opts.separator "Specific options:"
  
  opts.on( '-a', '--access_key_id AWS_ACCESS_KEY_ID', 'REQUIRED' ) do |access_key_id|
    options.access_key_id = access_key_id
  end
  
  opts.on( '-s', '--secret_access_key AWS_SECRET_ACCESS_KEY', 'REQUIRED' ) do |secret_access_key|
    options.secret_access_key = secret_access_key
  end
  
  opts.on( '-q', '--queue SQS_QUEUE_NAME', 'REQUIRED' ) do |queue_name|
    options.queue_name = queue_name
  end
  
  opts.on( '-t', '--tmpdir [TMPDIR]', 'Path to save temporary image files. Defaults to "/tmp"' ) do |tmp_path|
    options.tmp_path = tmp_path
  end
  
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end
opts.parse!( ARGV )

JackTheRIPper.tmp_path = options.tmp_path
queue = JackTheRIPper.get_queue( options.access_key_id,
  options.secret_access_key, options.queue_name )

while @keep_running do
  begin
    if JackTheRIPper.process_next_message( queue ) == false
      60.times { sleep( 1 ) if @keep_running }
    end
  rescue Exception => e
    STDERR.puts( "An Exception Occured!" )
    STDERR.puts( e.to_s )
    STDERR.puts( e.message )
    STDERR.puts( e.backtrace.join( "\n" ) )
    STDERR.puts( "\n\n" )
  end
end