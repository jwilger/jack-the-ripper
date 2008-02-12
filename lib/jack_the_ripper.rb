$:.unshift( File.expand_path( File.dirname( __FILE__ ) ) )
require 'yaml'
require 'rubygems'
gem 'right_aws', '= 1.5.0'
require 'right_aws'

module JackTheRIPper
  VERSION = '0.2.0dev'
  class << self
    def tmp_path
      @tmp_path || '/tmp'
    end
    
    def tmp_path=( path )
      @tmp_path = path
    end
    
    def process_next_message( queue )
      message = queue.receive
      return false if message.nil?
      processor = Processor.new( YAML::load( message.body ) )
      processor.process
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