$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../../lib' ) )

require 'rubygems'
gem 'mocha', '=0.5.6'

require 'test/unit'
require 'mocha'
require 'jack_the_ripper'

class TestJackTheRIPperProcessor < Test::Unit::TestCase
  def setup
    JackTheRIPper.stubs( :logger ).returns( stub_everything )
  end
  
  def test_should_convert_image_format_to_jpeg_and_put_resulting_file
    working_dir_path = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    JackTheRIPper.stubs( :tmp_path ).returns( working_dir_path )
    instruction = {
      :source_uri => 'http://example.com/source_file',
      :result_uri => 'http://example.com/result_file',
      :format => :jpg
    }
    processor = JackTheRIPper::Processor.new( instruction )
    
    source_file = mock
    source_file.expects( :delete )
    source_file.stubs( :path ).returns( working_dir_path + '/source.pdf' )
    result_file = mock
    result_file.expects( :put )
    result_file.expects( :delete )
    
    JackTheRIPper::HTTPFile.expects( :get ).
      with( instruction[ :source_uri ], working_dir_path, 'source' ).
      returns( source_file )
    JackTheRIPper::HTTPFile.expects( :new ).
      with( instruction[ :result_uri ], working_dir_path + '/result.jpg' ).
      returns( result_file )

    processor = JackTheRIPper::Processor.new( instruction )
    
    processor.expects(:`).with("file #{working_dir_path}/source.pdf").returns('')
    processor.expects( :` ).with( "sips -s format jpg -s formatOptions best #{working_dir_path}/source.pdf --out #{working_dir_path}/result.jpg" )
    File.expects( :exist? ).with( working_dir_path + '/result.jpg' ).returns( true )
    
    processor.process
  end

  def test_should_convert_eps_source_to_pdf_before_converting_to_final_format
    working_dir_path = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    JackTheRIPper.stubs( :tmp_path ).returns( working_dir_path )
    instruction = {
      :source_uri => 'http://example.com/source_file',
      :result_uri => 'http://example.com/result_file',
      :format => :jpg
    }
    processor = JackTheRIPper::Processor.new( instruction )
    
    source_file = mock
    source_file.expects( :delete )
    source_file.stubs( :path ).returns( working_dir_path + '/source.eps' )
    pdf_file = mock
    pdf_file.expects(:delete)
    pdf_file.stubs(:path).returns(working_dir_path + '/source.eps.pdf')
    result_file = mock
    result_file.expects( :put )
    result_file.expects( :delete )
    
    JackTheRIPper::HTTPFile.expects( :get ).
      with( instruction[ :source_uri ], working_dir_path, 'source' ).
      returns( source_file )
    JackTheRIPper::HTTPFile.expects(:new).with('', working_dir_path + '/source.eps.pdf').
      returns(pdf_file)
    JackTheRIPper::HTTPFile.expects( :new ).
      with( instruction[ :result_uri ], working_dir_path + '/result.jpg' ).
      returns( result_file )

    processor = JackTheRIPper::Processor.new( instruction )
    
    processor.expects(:`).with("file #{working_dir_path}/source.eps").
      returns('DOS EPS Binary File Postscript starts at byte 32 length ' +
              '4570373 TIFF starts at byte 4570405 length 575329\n')
    processor.expects(:`).with("pstopdf #{working_dir_path}/source.eps -o #{working_dir_path}/source.eps.pdf")
    processor.expects( :` ).with( "sips -s format jpg -s formatOptions best #{working_dir_path}/source.eps.pdf --out #{working_dir_path}/result.jpg" )
    File.expects( :exist? ).with( working_dir_path + '/result.jpg' ).returns( true )
    
    processor.process
  end

  def test_should_detect_alternate_postscript_tag_in_file_output
    working_dir_path = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    JackTheRIPper.stubs( :tmp_path ).returns( working_dir_path )
    instruction = {
      :source_uri => 'http://example.com/source_file',
      :result_uri => 'http://example.com/result_file',
      :format => :jpg
    }
    processor = JackTheRIPper::Processor.new( instruction )
    
    source_file = mock
    source_file.expects( :delete )
    source_file.stubs( :path ).returns( working_dir_path + '/source.eps' )
    pdf_file = mock
    pdf_file.expects(:delete)
    pdf_file.stubs(:path).returns(working_dir_path + '/source.eps.pdf')
    result_file = mock
    result_file.expects( :put )
    result_file.expects( :delete )
    
    JackTheRIPper::HTTPFile.expects( :get ).
      with( instruction[ :source_uri ], working_dir_path, 'source' ).
      returns( source_file )
    JackTheRIPper::HTTPFile.expects(:new).with('', working_dir_path + '/source.eps.pdf').
      returns(pdf_file)
    JackTheRIPper::HTTPFile.expects( :new ).
      with( instruction[ :result_uri ], working_dir_path + '/result.jpg' ).
      returns( result_file )

    processor = JackTheRIPper::Processor.new( instruction )
    
    processor.expects(:`).with("file #{working_dir_path}/source.eps").
      returns('PostScript document text conforming at level 3.1 - type EPS')
    processor.expects(:`).with("pstopdf #{working_dir_path}/source.eps -o #{working_dir_path}/source.eps.pdf")
    processor.expects( :` ).with( "sips -s format jpg -s formatOptions best #{working_dir_path}/source.eps.pdf --out #{working_dir_path}/result.jpg" )
    File.expects( :exist? ).with( working_dir_path + '/result.jpg' ).returns( true )
    
    processor.process
  end

  def test_should_convert_image_format_to_png_and_put_resulting_file
    working_dir_path = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    JackTheRIPper.stubs( :tmp_path ).returns( working_dir_path )
    instruction = {
      :source_uri => 'http://example.com/source_file',
      :result_uri => 'http://example.com/result_file',
      :format => :png
    }
    processor = JackTheRIPper::Processor.new( instruction )
    
    source_file = mock
    source_file.expects( :delete )
    source_file.stubs( :path ).returns( working_dir_path + '/source.pdf' )
    result_file = mock
    result_file.expects( :put )
    result_file.expects( :delete )
    
    JackTheRIPper::HTTPFile.expects( :get ).
      with( instruction[ :source_uri ], working_dir_path, 'source' ).
      returns( source_file )
    JackTheRIPper::HTTPFile.expects( :new ).
      with( instruction[ :result_uri ], working_dir_path + '/result.png' ).
      returns( result_file )

    processor = JackTheRIPper::Processor.new( instruction )
    
    processor.expects(:`).with("file #{working_dir_path}/source.pdf").returns('')
    processor.expects( :` ).with( "sips -s format png -s formatOptions best #{working_dir_path}/source.pdf --out #{working_dir_path}/result.png" )
    File.expects( :exist? ).with( working_dir_path + '/result.png' ).returns( true )
    
    processor.process
  end

  def test_should_scale_image_to_specified_max_dimension_and_put_resulting_file
    working_dir_path = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    JackTheRIPper.stubs( :tmp_path ).returns( working_dir_path )
    instruction = {
      :source_uri => 'http://example.com/source_file',
      :result_uri => 'http://example.com/result_file',
      :scale => 75
    }
    processor = JackTheRIPper::Processor.new( instruction )
    
    source_file = mock
    source_file.expects( :delete )
    source_file.stubs( :path ).returns( working_dir_path + '/source.jpg' )
    result_file = mock
    result_file.expects( :put )
    result_file.expects( :delete )
    
    JackTheRIPper::HTTPFile.expects( :get ).
      with( instruction[ :source_uri ], working_dir_path, 'source' ).
      returns( source_file )
    JackTheRIPper::HTTPFile.expects( :new ).
      with( instruction[ :result_uri ], working_dir_path + '/result.jpg' ).
      returns( result_file )

    processor = JackTheRIPper::Processor.new( instruction )
    
    processor.expects(:`).with("file #{working_dir_path}/source.jpg").returns('')
    processor.expects( :` ).with( "sips -Z 75 #{working_dir_path}/source.jpg --out #{working_dir_path}/result.jpg" )
    File.expects( :exist? ).with( working_dir_path + '/result.jpg' ).returns( true )
    
    processor.process
  end

  def test_should_pad_image_to_specified_width_and_height_and_put_resulting_file
    working_dir_path = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    JackTheRIPper.stubs( :tmp_path ).returns( working_dir_path )
    instruction = {
      :source_uri => 'http://example.com/source_file',
      :result_uri => 'http://example.com/result_file',
      :pad => '75x100 FFFFFF'
    }
    processor = JackTheRIPper::Processor.new( instruction )
    
    source_file = mock
    source_file.expects( :delete )
    source_file.stubs( :path ).returns( working_dir_path + '/source.jpg' )
    result_file = mock
    result_file.expects( :put )
    result_file.expects( :delete )
    
    JackTheRIPper::HTTPFile.expects( :get ).
      with( instruction[ :source_uri ], working_dir_path, 'source' ).
      returns( source_file )
    JackTheRIPper::HTTPFile.expects( :new ).
      with( instruction[ :result_uri ], working_dir_path + '/result.jpg' ).
      returns( result_file )

    processor = JackTheRIPper::Processor.new( instruction )
    
    processor.expects(:`).with("file #{working_dir_path}/source.jpg").returns('')
    processor.expects( :` ).with( "sips -p 75 100 --padColor FFFFFF #{working_dir_path}/source.jpg --out #{working_dir_path}/result.jpg" )
    File.expects( :exist? ).with( working_dir_path + '/result.jpg' ).returns( true )
    
    processor.process
  end
  
  def test_should_combine_options
    working_dir_path = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    JackTheRIPper.stubs( :tmp_path ).returns( working_dir_path )
    instruction = {
      :source_uri => 'http://example.com/source_file',
      :result_uri => 'http://example.com/result_file',
      :format => :jpg,
      :scale => 75,
      :pad => '75x100 FFFFFF'
    }
    processor = JackTheRIPper::Processor.new( instruction )
    
    source_file = mock
    source_file.expects( :delete )
    source_file.stubs( :path ).returns( working_dir_path + '/source.pdf' )
    result_file = mock
    result_file.expects( :put )
    result_file.expects( :delete )
    
    JackTheRIPper::HTTPFile.expects( :get ).
      with( instruction[ :source_uri ], working_dir_path, 'source' ).
      returns( source_file )
    JackTheRIPper::HTTPFile.expects( :new ).
      with( instruction[ :result_uri ], working_dir_path + '/result.jpg' ).
      returns( result_file )

    processor = JackTheRIPper::Processor.new( instruction )
    
    processor.expects(:`).with("file #{working_dir_path}/source.pdf").returns('')
    processor.expects( :` ).with( "sips -s format jpg -s formatOptions best -Z 75 -p 75 100 --padColor FFFFFF #{working_dir_path}/source.pdf --out #{working_dir_path}/result.jpg" )
    File.expects( :exist? ).with( working_dir_path + '/result.jpg' ).returns( true )
    
    processor.process
  end
  
  def test_should_raise_processor_error_if_sips_process_does_not_write_result_file
    working_dir_path = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    JackTheRIPper.stubs( :tmp_path ).returns( working_dir_path )
    instruction = {
      :source_uri => 'http://example.com/source_file',
      :result_uri => 'http://example.com/result_file'
    }
    processor = JackTheRIPper::Processor.new( instruction )
    
    source_file = stub_everything( :path => '/foo/bar.jpg' )
    JackTheRIPper::HTTPFile.stubs( :get ).returns( source_file )

    processor = JackTheRIPper::Processor.new( instruction )
    
    processor.stubs( :` ).returns( 'blah blah blah' )
    File.expects( :exist? ).with( working_dir_path + '/result.jpg' ).returns( false )
    
    begin
      processor.process
      fail "Expected ProcessorError to be raised."
    rescue JackTheRIPper::ProcessorError => e
      assert_equal 'blah blah blah', e.message
    end
  end
end
