require 'rexml/document'
require 'sqs/signed_request'

module SQS
  class Queue
    attr_accessor :name, :access_key_id, :secret_access_key
    
    def initialize( access_key_id, secret_access_key, name )
      @name = name
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
    end
    
    def next_message
      response = SignedRequest.send( access_key_id, secret_access_key, name,
        'ReceiveMessage' )
      response_xml = REXML::Document.new( response ).root
      message = response_xml.get_elements( '//Message' ).first
      receipt = message.get_elements( '//ReceiptHandle' ).first.text
      body = message.get_elements( '//Body' ).first.text
      return receipt, body
    end
    
    def delete_message( receipt )
      SignedRequest.send( access_key_id, secret_access_key, name,
        'DeleteMessage', 'ReceiptHandle' => receipt )
    end
    
    class << self
      def create!( access_key_id, secret_access_key, name )
        SignedRequest.send( access_key_id, secret_access_key, nil,
          'CreateQueue', 'QueueName' => name )
        new( access_key_id, secret_access_key, name )
      end
    end
  end
end