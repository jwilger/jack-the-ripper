$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../../vendor/mocha/lib' ) )
require 'test/unit'
require 'mocha'
require 'sqs/queue'

class TestSQSQueue < Test::Unit::TestCase
  def test_should_initialize_queue_object
    queue_name = 'myqueue'
    access_key_id = 'myaccesskey'
    secret_access_key = 'mysecretkey'
    queue = SQS::Queue.new( access_key_id, secret_access_key, queue_name )
    assert_equal queue_name, queue.name
    assert_equal access_key_id, queue.access_key_id
    assert_equal secret_access_key, queue.secret_access_key
  end
  
  def test_should_create_and_return_queue_with_specified_name
    queue_name = 'myqueue'
    access_key_id = 'myaccesskey'
    secret_access_key = 'mysecretkey'
    SQS::SignedRequest.expects( :send ).with( access_key_id, secret_access_key,
      nil, 'CreateQueue', 'QueueName' => queue_name )
    queue = SQS::Queue.create!( access_key_id, secret_access_key, queue_name )
    assert_equal queue_name, queue.name
    assert_equal access_key_id, queue.access_key_id
    assert_equal secret_access_key, queue.secret_access_key
  end
  
  def test_should_pull_a_message_from_the_queue_and_return_the_receipt_handle_and_message_body
    queue_name = 'myqueue'
    access_key_id = 'myaccesskey'
    secret_access_key = 'mysecretkey'
    expected_receipt = 'Z2hlcm1hbi5kZXNrdG9wLmFtYXpvbi5jb20=:AAABFoNJa/AAAAAAAAAANwAAAAAAAAAAAAAAAAAAAAQAAAEXAMPLE'
    expected_body = 'foo'
    sqs_response = <<-EOF
      <ReceiveMessageResponse>
        <ReceiveMessageResult>
          <Message>
            <MessageId>11YEJMCHE2DM483NGN40|3H4AA8J7EJKM0DQZR7E1|PT6DRTB278S4MNY77NJ0</MessageId>
            <ReceiptHandle>#{expected_receipt}</ReceiptHandle>
            <MD5OfBody>#{Digest::MD5.hexdigest( expected_body )}</MD5OfBody>
            <Body>#{expected_body}</Body>
          </Message>
        </ReceiveMessageResult>
        <ResponseMetadata>
          <RequestId>b5bf2332-e983-4d3e-941a-f64c0d21f00f</RequestId>
        </ResponseMetadata>
      </ReceiveMessageResponse>
    EOF
    SQS::SignedRequest.expects( :send ).with( access_key_id, secret_access_key,
      queue_name, 'ReceiveMessage' ).returns( sqs_response )
    
    queue = SQS::Queue.new( access_key_id, secret_access_key, queue_name )
    receipt, body = queue.next_message
    assert_equal expected_receipt, receipt
    assert_equal expected_body, body
  end
  
  def test_should_delete_a_message_from_the_queue
    queue_name = 'myqueue'
    access_key_id = 'myaccesskey'
    secret_access_key = 'mysecretkey'
    receipt = 'Z2hlcm1hbi5kZXNrdG9wLmFtYXpvbi5jb20=:AAABFoNJa/AAAAAAAAAANwAAAAAAAAAAAAAAAAAAAAQAAAEXAMPLE'
    SQS::SignedRequest.expects( :send ).with( access_key_id, secret_access_key,
      queue_name, 'DeleteMessage', 'ReceiptHandle' => receipt )
    
    queue = SQS::Queue.new( access_key_id, secret_access_key, queue_name )
    queue.delete_message( receipt )
  end
end