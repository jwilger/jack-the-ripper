$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../../vendor/mocha/lib' ) )
require 'test/unit'
require 'mocha'
require 'jack_the_ripper'

class TestJackTheRIPperHTTPFile < Test::Unit::TestCase
  def test_should_get_file_and_store_it_at_specified_path_and_return_http_file_instance
    http_result = Net::HTTPSuccess.allocate
    http_result.stubs( :content_type ).returns( 'application/pdf' )
    http_result.stubs( :read_body ).returns( 'file contents' )
    f = mock
    File.expects( :open ).with( '/tmp/source', 'w' ).yields( f )
    f.expects( :write ).with( 'file contents' )
    JackTheRIPper::HTTPFile.expects( :send_request ).
      with( 'http://example.com/file.pdf', :get ).
      returns( http_result )
    file = JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf',
      '/tmp', 'source' )
    assert_equal '/tmp/source', file.path
  end
  
  def test_should_get_file_via_redirect
    redirect = Net::HTTPRedirection.allocate
    redirect.stubs( :[] ).with( 'location' ).returns( 'http://example.com/file.pdf' )
    http_result = Net::HTTPSuccess.allocate
    http_result.stubs( :content_type ).returns( 'application/pdf' )
    http_result.stubs( :read_body ).returns( 'file contents' )
    JackTheRIPper::HTTPFile.expects( :send_request ).
      with( 'http://example.com/redirect_me', :get ).
      returns( redirect )
    JackTheRIPper::HTTPFile.expects( :send_request ).
      with( 'http://example.com/file.pdf', :get ).
      returns( http_result )
    f = stub_everything
    File.stubs( :open ).yields( f )
    JackTheRIPper::HTTPFile.get( 'http://example.com/redirect_me', '/tmp', 'source' )
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
    headers = { 'Content-Type' => 'image/jpeg' }
    data = 'file contents'
    File.expects( :read ).with( '/tmp/result.jpg' ).returns( data )
    http_response = Net::HTTPSuccess.allocate
    JackTheRIPper::HTTPFile.expects( :send_request ).
      with( 'http://example.com/result.jpg', :put, headers, Base64.encode64( data ) ).
      returns( http_response )
    f.put
  end
  
  def test_should_raise_remote_error_if_get_fails_due_to_server_error
    http_result = Net::HTTPServerError.allocate
    JackTheRIPper::HTTPFile.stubs( :send_request ).returns( http_result )
    assert_raises( JackTheRIPper::RemoteError ) do
      JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf',
        '/tmp', 'source' )
    end
  end
  
  def test_should_raise_processor_error_if_get_fails_due_to_404
    http_result = Net::HTTPNotFound.allocate
    JackTheRIPper::HTTPFile.stubs( :send_request ).returns( http_result )
    assert_raises( JackTheRIPper::ProcessorError ) do
      JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf',
        '/tmp', 'source' )
    end
  end
  
  def test_should_raise_processor_error_if_get_fails_due_to_invalid_uri
    assert_raises( JackTheRIPper::ProcessorError ) do
      JackTheRIPper::HTTPFile.get( 'http://example.com/file[invalid].pdf',
        '/tmp', 'source' )
    end
  end
  
  def test_should_raise_remote_error_if_get_fails_due_to_other_client_error
    http_result = Net::HTTPClientError.allocate
    JackTheRIPper::HTTPFile.stubs( :send_request ).returns( http_result )
    assert_raises( JackTheRIPper::RemoteError ) do
      JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf',
        '/tmp', 'source' )
    end
  end
  
  def test_should_raise_remote_error_if_get_redirects_too_many_times
    http_result = Net::HTTPRedirection.allocate
    http_result.expects( :[] ).at_least_once.
      with( 'location' ).returns( 'http://example.com/file.pdf' )
    JackTheRIPper::HTTPFile.stubs( :send_request ).returns( http_result )
    assert_raises( JackTheRIPper::RemoteError ) do
      JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf',
        '/tmp', 'source', 10 )
    end
  end
  
  def test_should_raise_remote_error_if_get_fails_due_to_uncaught_exception
    JackTheRIPper::HTTPFile.stubs( :send_request ).raises( Exception )
    assert_raises( JackTheRIPper::RemoteError ) do
      JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf', '/tmp', 'source' )
    end
  end
  
  def test_should_raise_remote_error_if_put_fails_due_to_server_error
    f = JackTheRIPper::HTTPFile.new( 'http://example.com/result.jpg',
      '/tmp/result.jpg' )
    File.stubs( :read ).returns( ' ' )
    http_response = Net::HTTPServerError.allocate
    JackTheRIPper::HTTPFile.stubs( :send_request ).returns( http_response )
    assert_raises( JackTheRIPper::RemoteError ) { f.put }
  end

  def test_should_raise_processor_error_if_put_fails_due_to_404
    f = JackTheRIPper::HTTPFile.new( 'http://example.com/result.jpg',
      '/tmp/result.jpg' )
    File.stubs( :read ).returns( ' ' )
    http_response = Net::HTTPNotFound.allocate
    JackTheRIPper::HTTPFile.stubs( :send_request ).returns( http_response )
    assert_raises( JackTheRIPper::ProcessorError ) { f.put }
  end
  
  def test_should_raise_processor_error_if_put_fails_due_to_invalid_uri
    f = JackTheRIPper::HTTPFile.new( 'http://example.com/result[invalid].jpg',
      '/tmp/result.jpg' )
    File.stubs( :read ).returns( ' ' )
    assert_raises( JackTheRIPper::ProcessorError ) { f.put }
  end
  
  def test_should_raise_remote_error_if_put_fails_due_to_other_client_error
    f = JackTheRIPper::HTTPFile.new( 'http://example.com/result.jpg',
      '/tmp/result.jpg' )
    File.stubs( :read ).returns( ' ' )
    http_response = Net::HTTPClientError.allocate
    JackTheRIPper::HTTPFile.stubs( :send_request ).returns( http_response )
    assert_raises( JackTheRIPper::RemoteError ) { f.put }
  end

  def test_should_raise_remote_error_if_put_fails_due_to_uncaught_exception
    f = JackTheRIPper::HTTPFile.new( 'http://example.com/result.jpg',
      '/tmp/result.jpg' )
    File.stubs( :read ).returns( ' ' )
    Net::HTTP.stubs( :start ).raises( Exception.new )
    assert_raises( JackTheRIPper::RemoteError ) { f.put }
  end
end