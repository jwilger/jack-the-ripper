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
      File.unlink( @path )
    end
    
    def put
      uri = URI.parse( @uri )
      content_type = MIME::Types.type_for( @path ).first.content_type
      Net::HTTP.start( uri.host, uri.port ) do |http|
        http.send_request( 'PUT', uri.request_uri, File.read( @path ), { 'Content-Type' => content_type } )
      end
    end
    
    class << self
      def get( uri, directory, basename )
        result = Net::HTTP.get_response( URI.parse( uri ) )
        ext = MIME::Types[ result.content_type ].first.extensions.first
        file_path = directory + '/' + basename + '.' + ext
        File.open( file_path, 'w' ) { |f| f.write( result.read_body ) }
        new( nil, file_path )
      end
    end
  end
end