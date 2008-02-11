require 'test/unit'
require 'sqs/signature'

class TestSQSSignature < Test::Unit::TestCase
  def test_should_generate_expected_signature_from_parameters
    params = {
      'Action' => 'CreateQueue',
      'QueueName' => 'queue2',
      'AWSAccessKeyId' => '0A8BDF2G9KCB3ZNKFA82',
      'SignatureVersion' => '1',
      'Timestamp' => '2007-01-12T12:00:00Z',
      'Version' => '2006-04-01'
    }
    sig = SQS::Signature.new( 'abc123', params )
    expected = CGI.escape( Base64.encode64( Digest::SHA1.hexdigest(
      'Action' + 'CreateQueue' +
      'AWSAccessKeyId' + '0A8BDF2G9KCB3ZNKFA82' +
      'QueueName' + 'queue2' +
      'SignatureVersion' + '1' +
      'Timestamp' + '2007-01-12T12:00:00Z' +
      'Version' + '2006-04-01' +
      'abc123'
    ) ) )
    assert_equal expected, sig.to_s
  end
end