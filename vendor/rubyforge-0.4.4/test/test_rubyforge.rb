require 'test/unit' unless defined? $ZENTEST and $ZENTEST

$TESTING = true
require 'rubyforge'

class FakeRubyForge < RubyForge
  HTML = "blah blah <form action=\"/frs/admin/editrelease.php?group_id=440&release_id=6948&package_id=491\" method=\"post\"> blah blah"

  attr_accessor :page, :form, :extheader, :requests, :scrape
  def run(page, form, extheader={})
    @page, @form, @extheader = page, form, extheader
    @requests ||= []
    @requests << { :url => page, :form => form, :headers => extheader }
    HTML
  end

  def scrape_project(proj)
    @scrape ||= []
    @scrape << proj
  end
end

class HTTPAccess2::Client
  attr_accessor :url, :form, :headers
  alias :old_post_content :post_content
  def post_content(url, form, headers)
    @url, @form, @headers = url, form, headers
    FakeRubyForge::HTML
  end
end

class TestRubyForge < Test::Unit::TestCase

  def setup
    srand(0)
    util_new FakeRubyForge
  end

  def teardown
    @rubyforge.autoconfig.replace @old_autoconfig
    @rubyforge.save_autoconfig
  end

  def test_initialize_bad
    assert_raise RuntimeError do
      RubyForge.new(RubyForge::CONFIG_F, "username" => nil)
    end
    assert_raise RuntimeError do
      RubyForge.new(RubyForge::CONFIG_F, "password" => nil)
    end
    assert_raise RuntimeError do
      RubyForge.new(RubyForge::CONFIG_F, "cookie_jar" => nil)
    end
  end

  def test_setup
    # TODO raise NotImplementedError, 'Need to write test_setup'
  end

  def test_login
    u, p = 'fooby', 's3kr3t'
    @rubyforge.userconfig['username'] = u
    @rubyforge.userconfig['password'] = p
    @rubyforge.login

    util_run('https://rubyforge.org/account/login.php',
             'form_pw' => p,
             'form_loginname' => u,
             'return_to' => '',
             'login' => 'Login')
  end

  def test_create_package
    @rubyforge.create_package(42, 'woot_pkg')

    util_run('/frs/admin/index.php',
             "submit" => "Create This Package",
             "group_id" => 42,
             "is_public" => 1,
             "package_name" => "woot_pkg",
             "func" => "add_package")
  end

  def test_delete_package
    @rubyforge.delete_package(42, 666)
    util_delete_package
  end

  def test_delete_package_package_name
    @rubyforge.delete_package(42, "woot_pkg")
    util_delete_package
  end

  def test_delete_package_undefined_package_name
    assert_raise RuntimeError do
      @rubyforge.delete_package(42, "blah")
    end
  end

  def test_delete_package_group_name
    @rubyforge.delete_package("seattlerb", 666)
    util_delete_package
  end

  def test_delete_package_undefined_group_name
    assert_raise RuntimeError do
      @rubyforge.delete_package("blah", 666)
    end
  end

  def test_add_file
    @rubyforge.autoconfig["package_ids"]["ringy_dingy"] = 314
    @rubyforge.autoconfig["release_ids"]["ringy_dingy"] ||= {}
    @rubyforge.autoconfig["release_ids"]["ringy_dingy"]["1.2.3"] = 43

    @rubyforge.add_file('seattlerb', 'ringy_dingy', '1.2.3', __FILE__)

    util_run('/frs/admin/editrelease.php?group_id=42&release_id=43&package_id=314',
             { "step2" => 1,
               "type_id" => 9999,
               "processor_id" => 8000,
               "submit" => "Add This File"},
             {"content-type"=> "multipart/form-data; boundary=___00__03__03__39__09__19__21__36___"})
  end

  def test_add_release
    @rubyforge.add_release(42, 666, '1.2.3', __FILE__)
    util_add_release
  end

  def test_add_release_multiple
    @rubyforge.add_release(42, 666, '1.2.3', __FILE__, __FILE__) # dunno if that'll work
    add_release = ({ :url=>"/frs/admin/qrs.php",
                     :form=>{"processor_id"=>8000,
                       "submit"=>"Release File",
                       "preformatted"=>0,
                       "release_changes"=>nil,
                       "type_id"=>9999,
                       "group_id"=>42,
                       "release_name"=>"1.2.3",
                       "release_notes"=>nil,
                       "package_id"=>666,
                       "release_date"=>"today"},
                     :headers=> {"content-type" => "multipart/form-data; boundary=___00__03__03__39__09__19__21__36___"}})
    add_file = ({ :url => '/frs/admin/editrelease.php?group_id=42&release_id=6948&package_id=666',
                  :form => { "step2" => 1,
                    "type_id" => 9999,
                    "processor_id" => 8000,
                    "submit" => "Add This File"},
                  :headers => {"content-type"=> "multipart/form-data; boundary=___23__06__24__24__12__01__38__39___"}})
    expected = [add_release, add_file]

    result = @rubyforge.requests
    result.each do |r|
      r[:form].delete "userfile"
    end

    assert_equal expected, result
  end

  def test_post_news
    @rubyforge.post_news("seattlerb", "my summary", "my news")

    util_run("/news/submit.php",
             "group_id"     => 42,
             "post_changes" => "y",
             "details"      => "my news",
             "summary"      => "my summary",
             "submit"       => "Submit")
  end

  def test_add_release_package_name
    @rubyforge.add_release(42, "woot_pkg", '1.2.3', __FILE__)
    util_add_release
  end

  def test_add_release_undefined_package_name
    assert_raise RuntimeError do
      @rubyforge.add_release(42, "blah", '1.2.3', __FILE__)
    end
  end

  def test_add_release_group_name
    @rubyforge.add_release("seattlerb", 666, '1.2.3', __FILE__)
    util_add_release
  end

  def test_add_release_undefined_group_name
    assert_raise RuntimeError do
      @rubyforge.add_release("blah", 666, '1.2.3', __FILE__)
    end
  end

  def test_lookup_id
    assert_equal 43, @rubyforge.lookup("package", 43)
  end

  def test_lookup_string_number
    assert_raise RuntimeError do
      @rubyforge.lookup("package", "43")
    end
  end

  def test_lookup_name
    @rubyforge.autoconfig["package_ids"]["ringy_dingy"] = 314
    assert_equal 314, @rubyforge.lookup("package", "ringy_dingy")
  end

  def test_lookup_undefined
    assert_raise RuntimeError do
      @rubyforge.lookup("package", "blah")
    end
  end

  def test_run
    util_new RubyForge
    result = @rubyforge.add_release(42, 666, '1.2.3', __FILE__)

    assert_equal 6948, result
    extheader = {"content-type"=> "multipart/form-data; boundary=___00__03__03__39__09__19__21__36___"}

    form = {
      "processor_id" => 8000,
      "submit" => "Release File",
      "preformatted" => 0,
      "release_changes" => nil,
      "type_id" => 9999,
      "group_id" => 42,
      "release_name" => "1.2.3",
      "release_notes" => nil,
      "package_id" => 666,
      "release_date" => "today"
    }

    client = @rubyforge.client
    assert client.form.delete("userfile")

    assert_equal 'http://rubyforge.org/frs/admin/qrs.php', client.url.to_s
    assert_equal form, client.form
    assert_equal extheader, client.headers
  end

  def util_new(klass)
    @rubyforge = klass.new
    @old_autoconfig = @rubyforge.autoconfig.dup

    data = { # REFACTOR
      "group_ids" => {},
      "package_ids" => {},
      "release_ids" => Hash.new { |h,k| h[k] = {} },
      "type_ids" => {},
      "processor_ids" => {"Any"=>8000},
    }

    @rubyforge.autoconfig.replace data

    @rubyforge.userconfig["release_date"] = "today"
    @rubyforge.autoconfig["type_ids"][".rb"] = 9999
    @rubyforge.autoconfig["group_ids"]["seattlerb"] = 42
    @rubyforge.autoconfig["package_ids"]["woot_pkg"] = 666
  end

  def util_run(page, form={}, extheader={})
    form_result = @rubyforge.form
    assert form_result.delete("userfile") unless extheader.empty?

    assert_equal page, @rubyforge.page.to_s
    assert_equal form, form_result
    assert_equal extheader, @rubyforge.extheader
  end

  def util_add_release
    util_run('/frs/admin/qrs.php',
             {"processor_id" => 8000,
               "submit" => "Release File",
               "preformatted" => 0,
               "release_changes" => nil,
               "type_id" => 9999,
               "group_id" => 42,
               "release_name" => "1.2.3",
               "release_notes" => nil,
               "package_id" => 666,
               "release_date" => "today"},
             {"content-type"=> "multipart/form-data; boundary=___00__03__03__39__09__19__21__36___"})
  end

  def util_delete_package
    util_run('/frs/admin/index.php',
             "submit" => "Delete",
             "really_sure" => "1",
             "group_id" => 42,
             "func" => "delete_package",
             "package_id" => 666,
             "sure" => "1")
  end
end
