$:.unshift( File.expand_path( File.dirname( __FILE__ ) + '/../../vendor/mocha/lib' ) )
require 'test/unit'
require 'mocha'
require 'jack_the_ripper/http_file'

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
    File.expects( :unlink ).with( '/tmp/some_file' )
    f.delete
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
      with( 'PUT', uri.request_uri, data, headers ).
      returns( http_response )
    f.put
  end
  
  def test_should_raise_exception_if_get_fails
    http_result = Net::HTTPServerError.allocate
    Net::HTTP.expects( :get_response ).
      with( URI.parse( 'http://example.com/file.pdf' ) ).
      returns( http_result )
    http_result.expects( :error! ).raises( Net::HTTPServerException.allocate )
    assert_raises( Net::HTTPServerException ) do
      JackTheRIPper::HTTPFile.get( 'http://example.com/file.pdf',
        '/tmp', 'source' )
    end
  end
  
  def test_should_raise_exception_if_put_fails
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
    http_conn.expects( :send_request ).
      with( 'PUT', uri.request_uri, data, headers ).
      returns( http_response )
    http_response.expects( :error! ).raises( Net::HTTPServerException.allocate )
    assert_raises( Net::HTTPServerException ) { f.put }
  end
end