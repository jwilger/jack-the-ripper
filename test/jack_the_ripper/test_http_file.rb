$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../../vendor/mocha/lib' ) )
require 'test/unit'
require 'mocha'
require 'jack_the_ripper'

class TestJackTheRIPperHTTPFile < Test::Unit::TestCase
  def test_should_get_file_and_store_it_at_specified_path_and_return_http_file_instance
    http_result = Net::HTTPSuccess.allocate
    http_result.stubs( :content_type ).returns( 'application/pdf' )
    http_result.stubs( :read_body ).returns( 'file contents' )
    Net::HTTP.expects( :get_response ).
      with( URI.parse( 'http://example.com/file.pdf' ) ).
      returns( http_result )
    file = mock
    File.expects( :open ).with( '/tmp/source.pdf', 'w' ).yields( file )
    file.expects( :write ).with( 'file contents' )
    file = JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf',
      '/tmp', 'source' )
    assert_equal '/tmp/source.pdf', file.path
  end
  
  def test_should_delete_file_from_path
    f = JackTheRIPper::HTTPFile.new( nil, '/tmp/some_file' )
    File.expects( :exist? ).with( '/tmp/some_file' ).returns( true )
    File.expects( :unlink ).with( '/tmp/some_file' )
    f.delete
  end
  
  def test_should_not_raise_exception_on_delete_if_file_does_not_exist
    f = JackTheRIPper::HTTPFile.new( nil, '/tmp/some_file' )
    File.expects( :exist? ).with( '/tmp/some_file' ).returns( false )
    assert_nothing_raised { f.delete }
  end
  
  def test_should_upload_file_to_specified_uri_via_put
    f = JackTheRIPper::HTTPFile.new( 'http://example.com/result.jpg',
      '/tmp/result.jpg' )
    uri = URI.parse( 'http://example.com/result.jpg' )
    http_conn = mock
    Net::HTTP.expects( :start ).
      with( uri.host, uri.port ).
      yields( http_conn )
    headers = { 'Content-Type' => 'image/jpeg' }
    data = 'file contents'
    File.expects( :read ).with( '/tmp/result.jpg' ).returns( data )
    http_response = Net::HTTPSuccess.allocate
    http_conn.expects( :send_request ).
      with( 'PUT', uri.request_uri, Base64.encode64( data ), headers ).
      returns( http_response )
    f.put
  end
  
  def test_should_raise_remote_error_if_get_fails_due_to_server_error
    http_result = Net::HTTPServerError.allocate
    Net::HTTP.expects( :get_response ).
      with( URI.parse( 'http://example.com/file.pdf' ) ).
      returns( http_result )
    assert_raises( JackTheRIPper::RemoteError ) do
      JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf',
        '/tmp', 'source' )
    end
  end
  
  def test_should_raise_processor_error_if_get_fails_due_to_client_error
    http_result = Net::HTTPClientError.allocate
    Net::HTTP.expects( :get_response ).
      with( URI.parse( 'http://example.com/file.pdf' ) ).
      returns( http_result )
    assert_raises( JackTheRIPper::ProcessorError ) do
      JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf',
        '/tmp', 'source' )
    end
  end

  def test_should_raise_remote_error_if_put_fails_due_to_server_error
    f = JackTheRIPper::HTTPFile.new( 'http://example.com/result.jpg',
      '/tmp/result.jpg' )
    uri = URI.parse( 'http://example.com/result.jpg' )
    http_conn = mock
    Net::HTTP.expects( :start ).
      with( uri.host, uri.port ).
      yields( http_conn )
    headers = { 'Content-Type' => 'image/jpeg' }
    data = 'file contents'
    File.expects( :read ).with( '/tmp/result.jpg' ).returns( data )
    http_response = Net::HTTPServerError.allocate
    http_conn.stubs( :send_request ).returns( http_response )
    assert_raises( JackTheRIPper::RemoteError ) { f.put }
  end

  def test_should_raise_processor_error_if_put_fails_due_to_client_error
    f = JackTheRIPper::HTTPFile.new( 'http://example.com/result.jpg',
      '/tmp/result.jpg' )
    uri = URI.parse( 'http://example.com/result.jpg' )
    http_conn = mock
    Net::HTTP.expects( :start ).
      with( uri.host, uri.port ).
      yields( http_conn )
    headers = { 'Content-Type' => 'image/jpeg' }
    data = 'file contents'
    File.expects( :read ).with( '/tmp/result.jpg' ).returns( data )
    http_response = Net::HTTPClientError.allocate
    http_conn.stubs( :send_request ).returns( http_response )
    assert_raises( JackTheRIPper::ProcessorError ) { f.put }
  end
end