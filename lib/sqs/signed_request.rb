require 'time'
require 'uri'
require 'net/http'
require 'sqs/signature'

module SQS
  module SignedRequest
    class << self
      def send( access_key_id, secret_access_key, queue, action, params = {} )
        params = params.merge( default_params( access_key_id, action ) )
        params.merge!( 'Signature' => Signature.new( secret_access_key, params ).to_s )
        uri = URI.parse( "http://queue.amazonaws.com/#{queue}" )
        response = Net::HTTP.post_form( uri, params )
        response.read_body
      end
      
      private
      
      def default_params( access_key_id, action )
        {
          'Action' => action,
          'AWSAccessKeyId' => access_key_id,
          'SignatureVersion' => '1',
          'Timestamp' => Time.now.utc.iso8601,
          'Version' => '2008-01-01'
        }
      end
    end
  end
end