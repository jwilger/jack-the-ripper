$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../../vendor/mocha/lib' ) )
require 'test/unit'
require 'mocha'
require 'jack_the_ripper/processor'

class TestJackTheRIPperProcessor < Test::Unit::TestCase
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
    
    processor.expects( :` ).with( "sips -s format jpg -s formatOptions best #{working_dir_path}/source.pdf --out #{working_dir_path}/result.jpg" )
    processor.expects( :` ).with( "say \"Image converted. Money in the bank!\"" )
    $?.stubs( :success? ).returns( true )
    
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
    
    processor.expects( :` ).with( "sips -s format png -s formatOptions best #{working_dir_path}/source.pdf --out #{working_dir_path}/result.png" )
    processor.expects( :` ).with( "say \"Image converted. Money in the bank!\"" )
    $?.stubs( :success? ).returns( true )
    
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
    
    processor.expects( :` ).with( "sips -Z 75 #{working_dir_path}/source.jpg --out #{working_dir_path}/result.jpg" )
    processor.expects( :` ).with( "say \"Image converted. Money in the bank!\"" )
    $?.stubs( :success? ).returns( true )
    
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
    
    processor.expects( :` ).with( "sips -p 75 100 --padColor FFFFFF #{working_dir_path}/source.jpg --out #{working_dir_path}/result.jpg" )
    processor.expects( :` ).with( "say \"Image converted. Money in the bank!\"" )
    $?.stubs( :success? ).returns( true )
    
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
    
    processor.expects( :` ).with( "sips -s format jpg -s formatOptions best -Z 75 -p 75 100 --padColor FFFFFF #{working_dir_path}/source.pdf --out #{working_dir_path}/result.jpg" )
    processor.expects( :` ).with( "say \"Image converted. Money in the bank!\"" )
    $?.stubs( :success? ).returns( true )
    
    processor.process
  end
  
  def test_should_raise_conversion_failed_exception_if_sips_process_exits_uncleanly
    working_dir_path = File.expand_path( File.dirname( __FILE__ ) + '/../../tmp' )
    JackTheRIPper.stubs( :tmp_path ).returns( working_dir_path )
    instruction = {
      :source_uri => 'http://example.com/source_file',
      :result_uri => 'http://example.com/result_file'
    }
    processor = JackTheRIPper::Processor.new( instruction )
    
    source_file = stub_everything( :path => '/foo/bar.jpg' )
    result_file = stub_everything

    JackTheRIPper::HTTPFile.stubs( :get ).returns( source_file )
    JackTheRIPper::HTTPFile.stubs( :new ).returns( result_file )

    processor = JackTheRIPper::Processor.new( instruction )
    
    processor.stubs( :` ).returns( 'blah blah blah' )
    $?.stubs( :success? ).returns( false )
    
    assert_raises( JackTheRIPper::Processor::ConversionFailed ) { processor.process }
  end
end