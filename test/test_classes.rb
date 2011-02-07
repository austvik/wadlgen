require 'test/unit'
require 'wadlgen'

class TestGenerate < Test::Unit::TestCase

  def test_application
    base = "http://www.example.com/"
    app = Wadlgen::Application.new(base)
    assert_equal base, app.base
  end

  def test_resources
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    assert_equal 1, app.resources.length
    assert_equal res, app.resources.first
    assert_equal app, res.application
    assert_equal path, res.path
  end

  def test_methods
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    method = res.add_method(:verb => 'GET', :action => 'resource')
    assert_equal res, method.resource
    assert_equal 1, res.methods.length
    assert_equal method, res.methods.first
    assert_equal 'GET', method.verb
    assert_equal 'resource', method.action
    assert_equal 'GET_resources', method.id
  end

end