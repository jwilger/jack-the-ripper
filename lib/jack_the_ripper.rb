$:.unshift( File.expand_path( File.dirname( __FILE__ ) ) )
require 'yaml'
module JackTheRIPper
  VERSION = '0.1.0'
  
  class << self
    def process_next_message( queue )
      receipt, message = queue.next_message
      processor = Processor.new( YAML::load( message ) )
      processor.process
      queue.delete_message( receipt )
    end
  end
end

require 'jack_the_ripper/processor'