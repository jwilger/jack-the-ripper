$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../../vendor/mocha/lib' ) )
require 'test/unit'
require 'mocha'
require 'sqs/signed_request'

class TestSQSSignedRequest < Test::Unit::TestCase
  def test_should_submit_signed_request_to_sqs_and_return_result_body
    time = Time.now
    Time.stubs( :now ).returns( time )
    req_params = {
      'Action' => 'ReceiveMessage',
      'AWSAccessKeyId' => 'mykey',
      'SignatureVersion' => '1',
      'Timestamp' => time.utc.iso8601,
      'Version' => '2008-01-01',
      'MaxNumberOfMessages' => '1'
    }
    signature = stub( :to_s => 'aws_signature' )
    SQS::Signature.expects( :new ).with( 'mysecret', req_params ).
      returns( signature )
    signed_params = req_params.merge( 'Signature' => 'aws_signature' )
    uri = URI.parse( 'http://queue.amazonaws.com/myqueue' )
    expected_body = 'message response'
    response = Net::HTTPSuccess.allocate
    response.stubs( :read_body ).returns( expected_body )
    Net::HTTP.expects( :post_form ).with( uri, signed_params ).returns( response )

    result = SQS::SignedRequest.send( 'mykey', 'mysecret', 'myqueue',
      'ReceiveMessage', { 'MaxNumberOfMessages' => '1' } )
    assert_equal expected_body, result
  end
end