require 'test/unit'
require 'wadlgen'

class Testparser < Test::Unit::TestCase

  def test_parse_simple_wadl
    document = <<HERE
<?xml version="1.0" encoding="UTF-8"?>
<application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl.xsd" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://wadl.dev.java.net/2009/02">
  <resources base="http://example.com/application/">
    <resource path="accounts">
      <method name="GET" id="GET_accounts">
        <request>
          <param name="format" style="query">
            <option value="html" mediaType="application/html"/>
            <option value="xml" mediaType="application/xml"/>
            <option value="json" mediaType="application/json"/>
          </param>
        </request>
        <response status="200">
          <representation mediaType="application/html" element="html"/>
          <representation mediaType="application/xml" element="accounts"/>
          <representation mediaType="application/json"/>
        </response>
        <response status="400">
          <representation mediaType="application/xml" element="Error"/>
        </response>
      </method>
    </resource>
  </resources>
</application>
HERE

    wadl = Wadlgen::Wadl.parse(document)
    assert_equal "http://example.com/application/", wadl.base
    assert_equal 1, wadl.resources.length
    resource = wadl.resources.first
    assert_equal 'accounts', resource.path
    assert_equal 1, resource.methods.length
    method = resource.methods.first
    assert_equal 'GET', method.verb
    assert_equal 1, method.requests.length
    request = method.requests.first
    assert_equal 1, request.parameters.length
    param = request.parameters.first
    assert_equal 'format', param.name
    assert_equal 'query', param.style
    assert_equal 3, param.options.length
    assert_equal 'html', param.options[0].value
    assert_equal 'application/html', param.options[0].media_type
    assert_equal 'xml', param.options[1].value
    assert_equal 'application/xml', param.options[1].media_type
    assert_equal 'json', param.options[2].value
    assert_equal 'application/json', param.options[2].media_type
    assert_equal 2, method.responses.length

    response = method.responses.first
    assert_equal 200, response.status
    assert_equal 3, response.representations.length
    assert_equal 'html', response.representations[0].element
    assert_equal 'application/html', response.representations[0].media_type
    assert_equal 'accounts', response.representations[1].element
    assert_equal 'application/xml', response.representations[1].media_type
    assert_nil response.representations[2].element
    assert_equal 'application/json', response.representations[2].media_type

    response = method.responses.last
    assert_equal 400, response.status
    assert_equal 1, response.representations.length
    assert_equal 'Error', response.representations[0].element
    assert_equal 'application/xml', response.representations[0].media_type
  end

  def test_roundtrip
    document = <<HERE
<?xml version="1.0" encoding="UTF-8"?>
<application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl.xsd" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://wadl.dev.java.net/2009/02">
  <resources base="http://example.com/application/">
    <resource path="accounts">
      <method name="GET" id="GET_accounts">
        <request>
          <param name="format" style="query">
            <option value="html" mediaType="application/html"/>
            <option value="xml" mediaType="application/xml"/>
            <option value="json" mediaType="application/json"/>
          </param>
        </request>
        <response status="200">
          <representation mediaType="application/html" element="html"/>
          <representation mediaType="application/xml" element="accounts"/>
          <representation mediaType="application/json"/>
        </response>
        <response status="400">
          <representation mediaType="application/xml" element="Error"/>
        </response>
      </method>
    </resource>
  </resources>
</application>
HERE

    wadl = Wadlgen::Wadl.parse document
    document2 = Wadlgen::Wadl.generate_wadl(wadl)
    assert_equal document, document2
    wadl2 = Wadlgen::Wadl.parse document2
    document3 = Wadlgen::Wadl.generate_wadl(wadl2)
    assert_equal document, document3
  end

end