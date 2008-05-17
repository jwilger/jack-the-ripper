require 'rubygems'
gem 'mocha', '=0.5.6'

require 'test/unit'
require 'mocha'
require 'jack_the_ripper'

class TestJackTheRIPper < Test::Unit::TestCase
  def test_should_allow_logger_to_be_set_and_retrieved
    logger = stub
    assert_nil JackTheRIPper.logger
    assert_nothing_raised { JackTheRIPper.logger = logger }
    assert_same logger, JackTheRIPper.logger
  end
  
  def test_should_process_one_message_from_the_queue_then_delete_the_message_and_return_true
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
    assert_equal true, JackTheRIPper.process_next_message( queue )
  end
  
  def test_should_not_delete_message_from_queue_if_conversion_fails_due_to_remote_error
    logger = stub_everything
    JackTheRIPper.logger = logger
    message = mock
    queue = stub_everything( :receive => message )
    message.stubs( :body ).returns( 'foo' )
    message.expects( :delete ).never
    processor = stub
    JackTheRIPper::Processor.stubs( :new ).returns( processor )
    processor.stubs( :process ).raises( JackTheRIPper::RemoteError.new( 'blah' ) )
    logger.expects( :warn ).with( 'Remote Error: blah' )
    assert_equal true, JackTheRIPper.process_next_message( queue )
  end
  
  def test_should_delete_message_from_queue_if_conversion_fails_due_to_processor_error
    logger = stub_everything
    JackTheRIPper.logger = logger
    message = mock
    queue = stub_everything( :receive => message )
    message.stubs( :body ).returns( 'foo' )
    message.expects( :delete )
    processor = stub
    JackTheRIPper::Processor.stubs( :new ).returns( processor )
    processor.stubs( :process ).raises( JackTheRIPper::ProcessorError.new( 'blah' ) )
    logger.expects( :error ).with( 'Processor Error: blah' )
    assert_equal true, JackTheRIPper.process_next_message( queue )
  end
  
  def test_should_return_false_if_there_are_no_messages_retrieved
    queue = mock
    queue.expects( :receive ).returns( nil )
    assert_equal false, JackTheRIPper.process_next_message( queue )
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
  
  def test_should_have_tmp_path_attribute
    assert_equal '/tmp', JackTheRIPper.tmp_path
    assert_nothing_raised { JackTheRIPper.tmp_path = '/foo/bar' }
    assert_equal '/foo/bar', JackTheRIPper.tmp_path
  end
end