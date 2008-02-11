require 'jack_the_ripper/http_file'

module JackTheRIPper
  class Processor
    WORKING_PATH = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    
    def initialize( instructions )
      @source_uri = instructions[ :source_uri ]
      @result_uri = instructions[ :result_uri ]
      @format = instructions[ :format ]
      @scale = instructions[ :scale ]
      @pad = instructions[ :pad ]
    end
    
    def process
      source_file = HTTPFile.get( @source_uri, WORKING_PATH, 'source' )
      result_ext = @format.nil? ? File.extname( source_file.path ) : ".#{@format}"
      result_path = WORKING_PATH + '/result' + result_ext
      `sips #{sips_args} #{source_file.path} --out #{result_path}`
      source_file.delete
      result_file = HTTPFile.new( @result_uri, result_path )
      result_file.put
      result_file.delete
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