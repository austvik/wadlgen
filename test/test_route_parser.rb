require 'test/unit'
require 'rails'
require 'active_support/core_ext/hash'
require "action_controller/railtie"
require 'wadlgen'

#
# Test Rails application
#
class WadlgenTestApp < Rails::Application
  routes.draw do
    resources :foos
    match "/bar" => "foos#bar"
  end
end

class FoosController < ActionController::Base
  respond_to :json, :xml, :html
  def bar
    self.response_body = "Hello World"
  end
end

class TestRouteParser < Test::Unit::TestCase

  def test_parse_routes

    app = Wadlgen::Wadl.parse_route(WadlgenTestApp, 'https://example.com/app')

    ress = app.resources.first
    assert_equal 'https://example.com/app', ress.base
    assert_equal 4, ress.resources.count
    res = ress.resources.first
    meth = res.methods.first
    assert_equal "GET", meth.name
    assert_equal "index", meth.id
  end

  def test_generate
    expected = <<HERE
<?xml version="1.0" encoding="UTF-8"?>
<application xmlns="http://wadl.dev.java.net/2009/02" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl.xsd" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <resources base="https://example.com/app">
    <resource path="/foos(.:format)">
      <method id="index" name="GET">
        <request>
          <param name="format" style="query">
            <option mediaType="application/json" value="json"/>
            <option mediaType="application/xml" value="xml"/>
            <option mediaType="application/html" value="html"/>
          </param>
        </request>
        <response status="200">
          <representation element="json" mediaType="application/json"/>
          <representation element="xml" mediaType="application/xml"/>
          <representation element="html" mediaType="application/html"/>
        </response>
      </method>
      <method id="create" name="POST">
        <request>
          <param name="format" style="query">
            <option mediaType="application/json" value="json"/>
            <option mediaType="application/xml" value="xml"/>
            <option mediaType="application/html" value="html"/>
          </param>
          <param name="id" style="query"/>
        </request>
        <response status="200">
          <representation element="json" mediaType="application/json"/>
          <representation element="xml" mediaType="application/xml"/>
          <representation element="html" mediaType="application/html"/>
        </response>
      </method>
    </resource>
    <resource path="/foos/new(.:format)">
      <method id="new" name="GET">
        <request>
          <param name="format" style="query">
            <option mediaType="application/json" value="json"/>
            <option mediaType="application/xml" value="xml"/>
            <option mediaType="application/html" value="html"/>
          </param>
          <param name="id" style="query"/>
        </request>
        <response status="200">
          <representation element="json" mediaType="application/json"/>
          <representation element="xml" mediaType="application/xml"/>
          <representation element="html" mediaType="application/html"/>
        </response>
      </method>
    </resource>
    <resource path="/foos/:id(.:format)">
      <method id="show" name="GET">
        <request>
          <param name="format" style="query">
            <option mediaType="application/json" value="json"/>
            <option mediaType="application/xml" value="xml"/>
            <option mediaType="application/html" value="html"/>
          </param>
          <param name="id" style="query"/>
        </request>
        <response status="200">
          <representation element="json" mediaType="application/json"/>
          <representation element="xml" mediaType="application/xml"/>
          <representation element="html" mediaType="application/html"/>
        </response>
      </method>
      <method id="update" name="PUT">
        <request>
          <param name="format" style="query">
            <option mediaType="application/json" value="json"/>
            <option mediaType="application/xml" value="xml"/>
            <option mediaType="application/html" value="html"/>
          </param>
          <param name="id" style="query"/>
        </request>
        <response status="200">
          <representation element="json" mediaType="application/json"/>
          <representation element="xml" mediaType="application/xml"/>
          <representation element="html" mediaType="application/html"/>
        </response>
      </method>
      <method id="destroy" name="DELETE">
        <request>
          <param name="format" style="query">
            <option mediaType="application/json" value="json"/>
            <option mediaType="application/xml" value="xml"/>
            <option mediaType="application/html" value="html"/>
          </param>
          <param name="id" style="query"/>
        </request>
        <response status="200">
          <representation element="json" mediaType="application/json"/>
          <representation element="xml" mediaType="application/xml"/>
          <representation element="html" mediaType="application/html"/>
        </response>
      </method>
    </resource>
    <resource path="/bar(.:format)">
      <method id="bar">
        <request>
          <param name="format" style="query">
            <option mediaType="application/json" value="json"/>
            <option mediaType="application/xml" value="xml"/>
            <option mediaType="application/html" value="html"/>
          </param>
        </request>
        <response status="200">
          <representation element="json" mediaType="application/json"/>
          <representation element="xml" mediaType="application/xml"/>
          <representation element="html" mediaType="application/html"/>
        </response>
      </method>
    </resource>
  </resources>
</application>
HERE

    res = Wadlgen::Wadl.generate(WadlgenTestApp, 'https://example.com/app')
    assert_equal expected, res
  end

end
