require 'uri'
require 'net/http'
require 'net/https'
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
    
    def logger
      self.class.logger
    end
    
    def delete
      logger.debug "Deleting file #{@path}"
      File.unlink( @path ) if File.exist?( @path )
    end
    
    def put( uri = nil, redirection_limit = 10 )
      if redirection_limit == 0
        raise RemoteError, "Too many redirects for PUT: #{uri}"
      end
      logger.info "PUTing file: #{@uri}"
      content_type = MIME::Types.type_for( @path ).first.content_type
      result = HTTPFile.send_request( uri || @uri, :put, { 'Content-Type' => content_type }, Base64.encode64( File.read( @path ) ) )
      case result
      when Net::HTTPSuccess
        # ok
        logger.info "File PUT successful"
      when Net::HTTPRedirection
        logger.info "Got redirected to #{result[ 'location' ]}"
        put( result[ 'location' ], redirection_limit - 1 )
      when Net::HTTPNotFound
        raise ProcessorError, "Got #{result.code} #{result.message} for PUT: #{@uri}"
      else
        raise RemoteError, "Got #{result.code} #{result.message} for PUT: #{@uri}"
      end
    rescue ProcessorError, RemoteError => e
      raise e
    rescue Exception => e
      raise RemoteError, "Exception during GET: #{@uri} - #{e.class}: #{e.message}"
    end
    
    class << self
      def logger
        JackTheRIPper.logger || Proc.new{ l = Logger.new( STDERR ); l.level = Logger::ERROR; l }.call
      end
      
      def get( uri, directory, basename, redirection_limit = 10 )
        logger.info "GETing file: #{uri}"
        if redirection_limit == 0
          raise RemoteError, "Too many redirects for GET: #{uri}"
        end
        result = send_request( uri, :get )
        case result
        when Net::HTTPSuccess
          logger.info "File GET successful"
          file_path = directory + '/' + basename
          File.open( file_path, 'w' ) { |f| f.write( result.read_body ) }
          logger.debug "File stored at #{file_path}"
          new( nil, file_path )
        when Net::HTTPRedirection
          logger.info "Got redirected to #{result[ 'location' ]}"
          get( result[ 'location' ], directory, basename, redirection_limit - 1 )
        when Net::HTTPNotFound
          raise ProcessorError, "Got #{result.code} #{result.message} for GET: #{uri}"
        else
          raise RemoteError, "Got #{result.code} #{result.message} for GET: #{uri}"
        end
      rescue ProcessorError, RemoteError => e
        raise e
      rescue Exception => e
        raise RemoteError, "Exception during GET: #{uri} - #{e.class}: #{e.message}"
      end

      def send_request( uri, method, headers = {}, body = nil )
        uri = URI.parse( uri )
        http = Net::HTTP.new( uri.host, uri.port )
        http.use_ssl = true if uri.scheme == 'https'
        http.start do |h|
          logger.debug "HTTP#{ uri.scheme == 'https' ? 'S' : '' } connection started."
          h.send_request( method.to_s.upcase, uri.request_uri, body, headers )
        end
      end
    end
  end
end