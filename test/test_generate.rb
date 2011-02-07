require 'test/unit'
require 'wadlgen'

class TestGenerate < Test::Unit::TestCase

  def test_very_simple_route

    expected = <<HERE
<?xml version="1.0" encoding="UTF-8"?>
<application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl.xsd" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://wadl.dev.java.net/2009/02">
  <resources base="http://example.com/application/">
    <resource path="accounts">
      <method name="GET" id="GET_accounts">
        <request/>
        <response/>
      </method>
    </resource>
  </resources>
</application>
HERE
    
    wadl = Wadlgen::Wadl.new
    app = Wadlgen::Application.new("http://example.com/application/")
    accounts = app.add_resource("accounts")
    get = accounts.add_method(:verb => 'GET', :action => 'account')
    result = wadl.generate_wadl app

    assert_equal expected, result

  end

end