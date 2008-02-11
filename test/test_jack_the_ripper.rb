$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../vendor/mocha/lib' ) )
require 'test/unit'
require 'mocha'
require 'jack_the_ripper'

class TestJackTheRIPper < Test::Unit::TestCase
  def test_should_process_one_message_from_the_queue_then_delete_the_message
    queue = mock
    body = YAML::dump( { :foo => 'bar' } )
    queue.expects( :next_message ).returns( [ 'receipt_handle', body ] )
    queue.expects( :delete_message ).with( 'receipt_handle' )
    processor = mock
    JackTheRIPper::Processor.expects( :new ).with( { :foo => 'bar' } ).
      returns( processor )
    processor.expects( :process )
    JackTheRIPper.process_next_message( queue )
  end
end