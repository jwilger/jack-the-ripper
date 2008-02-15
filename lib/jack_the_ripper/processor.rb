require 'jack_the_ripper/http_file'

module JackTheRIPper
  class Processor
    def initialize( instructions )
      @source_uri = instructions[ :source_uri ]
      @result_uri = instructions[ :result_uri ]
      @format = instructions[ :format ]
      @scale = instructions[ :scale ]
      @pad = instructions[ :pad ]
    end
    
    def process
      JackTheRIPper.logger.debug "Processing message"
      source_file = HTTPFile.get( @source_uri, JackTheRIPper.tmp_path, 'source' )
      JackTheRIPper.logger.debug "Source file retrieved."
      result_ext = @format.nil? ? File.extname( source_file.path ) : ".#{@format}"
      result_path = JackTheRIPper.tmp_path + '/result' + result_ext
      cmd = "sips #{sips_args} #{source_file.path} --out #{result_path}"
      output = `#{cmd}`
      JackTheRIPper.logger.debug "Ran command #{cmd}"
      raise ProcessorError, output unless File.exist?( result_path )
      result_file = HTTPFile.new( @result_uri, result_path )
      result_file.put
      `say -v "Bad News" "Image converted money in the ba-ank."`
    ensure
      source_file.delete unless source_file.nil?
      result_file.delete unless result_file.nil?
    end
    
    private
    
    def sips_args
      args = []
      args << "-s format #{@format} -s formatOptions best" if @format
      args << "-Z #{@scale}" if @scale
      if @pad
        dimensions, color = @pad.split( /\s/, 2 )
        args << "-p #{dimensions.sub( 'x', ' ' )}"
        args << "--padColor #{color}" if color
      end
      args.join( ' ' )
    end
  end
end