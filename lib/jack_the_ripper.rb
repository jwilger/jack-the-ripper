$:.unshift( File.expand_path( File.dirname( __FILE__ ) ) )
require 'yaml'
require 'rubygems'
gem 'right_aws', '= 1.5.0'
require 'right_aws'

module JackTheRIPper
  VERSION = '0.1.0'
  
  class << self
    def process_next_message( queue )
      message = queue.receive
      processor = Processor.new( YAML::load( message.body ) )
      processor.process
      message.delete
    end
    
    def get_queue( access_key_id, secret_access_key, queue_name )
      RightAws::Sqs.new( access_key_id, secret_access_key ).
        queue( queue_name, true, 240 )
    end
  end
end

require 'jack_the_ripper/processor'