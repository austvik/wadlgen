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
    assert_equal "http://example.com/application/", wadl.resources.base
    assert_equal 1, wadl.resources.resources.length
    resource = wadl.resources.resources.first
    assert_equal 'accounts', resource.path
    assert_equal 1, resource.methods.length
    method = resource.methods.first
    assert_equal 'GET', method.name
    assert method.request
    request = method.request
    assert_equal 1, request.params.length
    param = request.params.first
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
  <doc title="application">
    Text about Application
  </doc>
  <resources base="http://example.com/application/">
    <doc title="resources">
      Text about Resources
    </doc>
    <resource path="accounts">
      <doc title="resource">
        Text about Resource
      </doc>
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

  def test_complete_wadl

    complete = <<HERE
<?xml version="1.0" encoding="UTF-8"?>
<tns:application xmlns:tns="http://wadl.dev.java.net/2009/02" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl2.xsd ">
  <tns:doc title="" tns:lang=""/>
  <tns:grammars>
    <tns:doc title="" tns:lang=""/>
    <tns:include href="http://tempuri.org">
      <tns:doc title="" tns:lang=""/>
    </tns:include>
  </tns:grammars>
  <tns:resources base="http://tempuri.org">
    <tns:doc title="" tns:lang=""/>
    <tns:resource id="idvalue0" path="" queryType="application/x-www-form-urlencoded" type="">
      <tns:doc title="" tns:lang=""/>
      <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue1" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
        <tns:doc title="" tns:lang=""/>
        <tns:option mediaType="" value="">
          <tns:doc title="" tns:lang=""/>
        </tns:option>
        <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
          <tns:doc title="" tns:lang=""/>
        </tns:link>
      </tns:param>
      <tns:method href="http://tempuri.org" id="idvalue2" name="GET">
        <tns:doc title="" tns:lang=""/>
        <tns:request>
          <tns:doc title="" tns:lang=""/>
          <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue3" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
            <tns:doc title="" tns:lang=""/>
            <tns:option mediaType="" value="">
              <tns:doc title="" tns:lang=""/>
            </tns:option>
            <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
              <tns:doc title="" tns:lang=""/>
            </tns:link>
          </tns:param>
          <tns:representation element="QName" href="http://tempuri.org" id="idvalue4" mediaType="" profile="">
            <tns:doc title="" tns:lang=""/>
            <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue5" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
              <tns:doc title="" tns:lang=""/>
              <tns:option mediaType="" value="">
                <tns:doc title="" tns:lang=""/>
              </tns:option>
              <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
                <tns:doc title="" tns:lang=""/>
              </tns:link>
            </tns:param>
          </tns:representation>
        </tns:request>
        <tns:response status="">
          <tns:doc title="" tns:lang=""/>
          <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue6" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
            <tns:doc title="" tns:lang=""/>
            <tns:option mediaType="" value="">
              <tns:doc title="" tns:lang=""/>
            </tns:option>
            <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
              <tns:doc title="" tns:lang=""/>
            </tns:link>
          </tns:param>
          <tns:representation element="QName" href="http://tempuri.org" id="idvalue7" mediaType="" profile="">
            <tns:doc title="" tns:lang=""/>
            <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue8" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
              <tns:doc title="" tns:lang=""/>
              <tns:option mediaType="" value="">
                <tns:doc title="" tns:lang=""/>
              </tns:option>
              <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
                <tns:doc title="" tns:lang=""/>
              </tns:link>
            </tns:param>
          </tns:representation>
        </tns:response>
      </tns:method>
    </tns:resource>
  </tns:resources>
  <tns:resource_type id="idvalue9">
    <tns:doc title="" tns:lang=""/>
    <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue10" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
      <tns:doc title="" tns:lang=""/>
      <tns:option mediaType="" value="">
        <tns:doc title="" tns:lang=""/>
      </tns:option>
      <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
        <tns:doc title="" tns:lang=""/>
      </tns:link>
    </tns:param>
    <tns:method href="http://tempuri.org" id="idvalue11" name="GET">
      <tns:doc title="" tns:lang=""/>
      <tns:request>
        <tns:doc title="" tns:lang=""/>
        <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue12" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
          <tns:doc title="" tns:lang=""/>
          <tns:option mediaType="" value="">
            <tns:doc title="" tns:lang=""/>
          </tns:option>
          <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
            <tns:doc title="" tns:lang=""/>
          </tns:link>
        </tns:param>
        <tns:representation element="QName" href="http://tempuri.org" id="idvalue13" mediaType="" profile="">
          <tns:doc title="" tns:lang=""/>
          <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue14" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
            <tns:doc title="" tns:lang=""/>
            <tns:option mediaType="" value="">
              <tns:doc title="" tns:lang=""/>
            </tns:option>
            <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
              <tns:doc title="" tns:lang=""/>
            </tns:link>
          </tns:param>
        </tns:representation>
      </tns:request>
      <tns:response status="">
        <tns:doc title="" tns:lang=""/>
        <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue15" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
          <tns:doc title="" tns:lang=""/>
          <tns:option mediaType="" value="">
            <tns:doc title="" tns:lang=""/>
          </tns:option>
          <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
            <tns:doc title="" tns:lang=""/>
          </tns:link>
        </tns:param>
        <tns:representation element="QName" href="http://tempuri.org" id="idvalue16" mediaType="" profile="">
          <tns:doc title="" tns:lang=""/>
          <tns:param default="" fixed="" href="http://tempuri.org" id="idvalue17" name="NMTOKEN" path="" repeating="false" required="false" style="plain" type="xs:string">
            <tns:doc title="" tns:lang=""/>
            <tns:option mediaType="" value="">
              <tns:doc title="" tns:lang=""/>
            </tns:option>
            <tns:link rel="token" resource_type="http://tempuri.org" rev="token">
              <tns:doc title="" tns:lang=""/>
            </tns:link>
          </tns:param>
        </tns:representation>
      </tns:response>
    </tns:method>
  </tns:resource_type>
</tns:application>
HERE
    wadl = Wadlgen::Wadl.parse complete
    document = Wadlgen::Wadl.generate_wadl(wadl)

    # TODO: Remove
    p wadl

    assert_equal complete, document
  end

end