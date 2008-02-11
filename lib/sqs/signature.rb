require 'base64'
require 'digest/sha1'
require 'cgi'

module SQS
  class Signature
    def initialize( secret, params )
      @params = params
      @secret = secret
    end
    
    def to_s
      p_str = param_keys.inject( '' ) { |s,k| s + k + @params[ k ] }
      CGI.escape( Base64.encode64( Digest::SHA1.hexdigest( p_str + @secret ) ) )
    end
    
    private
    
    def param_keys
      @params.keys.sort_by { |k| k.downcase }
    end
  end
end