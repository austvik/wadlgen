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
    structure = {'accounts' => ['GET']}
    result = wadl.generate_wadl "http://example.com/application/", structure

    assert_equal expected, result

  end

end