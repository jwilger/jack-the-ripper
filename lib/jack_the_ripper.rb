$:.unshift( File.expand_path( File.dirname( __FILE__ ) ) )
VENDOR_DIR = File.expand_path( File.dirname( __FILE__ ) + '/../vendor' )
$:.unshift( VENDOR_DIR + '/right_aws-1.5.0/lib' )
$:.unshift( VENDOR_DIR + '/right_http_connection-1.2.1/lib' )
require 'yaml'
require 'right_aws'

module JackTheRIPper
  VERSION = '1.3.1'
  
  class RemoteError < StandardError; end
  class ProcessorError < StandardError; end
  
  class << self
    attr_accessor :logger
    
    def tmp_path
      @tmp_path ||= '/tmp'
    end
    
    def tmp_path=( path )
      @tmp_path = path
    end
    
    def process_next_message( queue )
      logger.debug "Checking queue for message."
      message = queue.receive
      return false if message.nil?
      logger.debug "Message found:"
      logger.debug message.body
      processor = Processor.new( YAML::load( message.body ) )
      processor.process
      message.delete
      logger.debug "Message deleted."
      true
    rescue RemoteError => e
      logger.warn( 'Remote Error: ' + e.message )
      true
    rescue ProcessorError => e
      logger.error( 'Processor Error: ' + e.message )
      logger.debug "Message deleted."
      message.delete
      true
    end
    
    def get_queue( access_key_id, secret_access_key, queue_name )
      RightAws::Sqs.new( access_key_id, secret_access_key ).
        queue( queue_name, true, 240 )
    end
  end
end

require 'jack_the_ripper/processor'