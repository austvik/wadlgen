require 'test/unit'
require 'wadlgen'

class TestGenerate < Test::Unit::TestCase

  def test_very_simple_route

    expected = <<HERE
<?xml version="1.0" encoding="UTF-8"?>
<application xmlns="http://wadl.dev.java.net/2009/02" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl.xsd" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">
  <grammars>
    <include href="http://www.austvik.net/"/>
  </grammars>
  <resources base="http://example.com/application/">
    <resource path="accounts">
      <method id="accounts" name="GET">
        <request>
          <param name="format" style="query">
            <option mediaType="application/html" value="html"/>
            <option mediaType="application/xml" value="xml"/>
            <option mediaType="application/json" value="json"/>
            <link rel="true" resource_type="application/xml" rev="1.0"/>
          </param>
        </request>
        <response status="200">
          <representation element="html" mediaType="application/html"/>
          <representation element="accounts" mediaType="application/xml"/>
          <representation mediaType="application/json"/>
        </response>
        <response status="400">
          <representation element="Error" mediaType="application/xml"/>
        </response>
      </method>
    </resource>
  </resources>
</application>
HERE
    
    app = Wadlgen::Application.new
    grammars = app.add_grammars
    grammars.add_include("http://www.austvik.net/")
    resources = app.add_resources("http://example.com/application/")
    accounts = resources.add_resource(nil, "accounts")
    get = accounts.add_method('GET', 'accounts')
    req = get.add_request
    query = req.add_param('format', 'query')
    query.add_option('html', 'application/html')
    query.add_option('xml', 'application/xml')
    query.add_option('json', 'application/json')
    query.add_link('application/xml', '1.0', 'true')
    success = get.add_response(200)
    success.add_representation('application/html', 'html')
    success.add_representation('application/xml', 'accounts')
    success.add_representation('application/json')
    err = get.add_response(400)
    err.add_representation('application/xml', 'Error')
    result = Wadlgen::Wadl.generate_wadl app

    assert_equal expected, result

  end

end