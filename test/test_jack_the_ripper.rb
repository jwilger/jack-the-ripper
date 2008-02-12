$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../vendor/mocha/lib' ) )
require 'test/unit'
require 'mocha'
require 'jack_the_ripper'

class TestJackTheRIPper < Test::Unit::TestCase
  def test_should_process_one_message_from_the_queue_then_delete_the_message
    queue = mock
    message = mock
    body = YAML::dump( { :foo => 'bar' } )
    queue.expects( :receive ).returns( message )
    message.expects( :delete )
    message.stubs( :body ).returns( body )
    processor = mock
    JackTheRIPper::Processor.expects( :new ).with( { :foo => 'bar' } ).
      returns( processor )
    processor.expects( :process )
    JackTheRIPper.process_next_message( queue )
  end
  
  def test_should_instantiate_queue_and_return_it
    sqs = mock
    queue = stub
    sqs.expects( :queue ).with( 'myqueue', true, 240 ).returns( queue )
    RightAws::Sqs.expects( :new ).with( 'myaccesskeyid', 'mysecretaccesskey' ).
      returns( sqs )
    assert_same queue, JackTheRIPper.get_queue( 'myaccesskeyid',
      'mysecretaccesskey', 'myqueue' )
  end
end