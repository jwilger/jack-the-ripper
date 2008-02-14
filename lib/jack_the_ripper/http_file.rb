require 'uri'
require 'net/http'
require 'rubygems'
gem 'mime-types'
require 'mime/types'

module JackTheRIPper
  class HTTPFile
    attr_reader :path
    
    def initialize( uri, path )
      @uri = uri
      @path = path
    end
    
    def delete
      File.unlink( @path ) if File.exist?( @path )
    end
    
    def put
      uri = URI.parse( @uri )
      content_type = MIME::Types.type_for( @path ).first.content_type
      Net::HTTP.start( uri.host, uri.port ) do |http|
        result = http.send_request( 'PUT', uri.request_uri, Base64.encode64( File.read( @path ) ), { 'Content-Type' => content_type } )
        case result
        when Net::HTTPSuccess
          # ok
        when Net::HTTPClientError
          raise ProcessorError, "Got #{result.code} #{result.message} for PUT: #{@uri}"
        else
          raise RemoteError, "Got #{result.code} #{result.message} for PUT: #{@uri}"
        end
      end
    rescue Timeout::Error => e
      raise RemoteError, "Got Timeout Error for PUT: #{@uri}"
    rescue Errno::ECONNREFUSED => e
      raise RemoteError, "Connection Refused during PUT: #{@uri}"
    end
    
    class << self
      def get( uri, directory, basename, redirection_limit = 10 )
        if redirection_limit == 0
          raise ProcessorError, "Too many redirects for GET: #{uri}"
        end
        result = Net::HTTP.get_response( URI.parse( uri ) )
        case result
        when Net::HTTPSuccess
          file_path = directory + '/' + basename
          File.open( file_path, 'w' ) { |f| f.write( result.read_body ) }
          new( nil, file_path )
        when Net::HTTPRedirection
          get( result[ 'location' ], directory, basename, redirection_limit - 1 )
        when Net::HTTPClientError
          raise ProcessorError, "Got #{result.code} #{result.message} for GET: #{uri}"
        else
          raise RemoteError, "Got #{result.code} #{result.message} for GET: #{uri}"
        end
      rescue Timeout::Error => e
        raise RemoteError, "Got Timeout Error for GET: #{uri}"
      rescue Errno::ECONNREFUSED => e
        raise RemoteError, "Connection Refused during GET: #{uri}"
      end
    end
  end
end