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

  def test_has_resource
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    res2 = app.add_resource('applications')
    assert app.has_resource? path
    assert app.has_resource? 'applications'
    assert !app.has_resource?('something')
  end

  def test_get_resource
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    res2 = app.add_resource('applications')
    assert_equal res2, app.get_resource('applications')
    res3 = app.get_resource('users')
    assert_equal 'users', res3.path
    assert_equal app, res3.application
  end

  def test_methods
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    method = res.add_method('GET', 'resource')
    assert_equal res, method.resource
    assert_equal 1, res.methods.length
    assert_equal method, res.methods.first
    assert_equal 'GET', method.verb
    assert_equal 'resource', method.action
    assert_equal 'GET_resources', method.id
  end

  def test_has_method
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    res.add_method('GET', 'resource')
    res.add_method('POST', 'resource')
    assert res.has_method? 'GET', 'resource'
    assert res.has_method? 'POST', 'resource'
    assert !res.has_method?('GET', 'something')
    assert !res.has_method?('PUT', 'resource')
    assert !res.has_method?('POST', 'something')
  end

  def test_get_method
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    m1 = res.add_method('GET', 'resource')
    m2 = res.add_method('POST', 'resource')
    assert_equal m1, res.get_method('GET', 'resource')
    assert_equal m2, res.get_method('POST', 'resource')
    m3 = res.get_method('GET', 'user')
    assert_equal res, m3.resource
  end

  def test_response
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    method = res.add_method('GET', 'resource')
    response = method.add_response(200)
    assert_equal 200, response.status
    assert_equal method, response.method
    assert_equal 1, method.responses.length
    assert_equal response, method.responses.first
  end

  def test_representation
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    method = res.add_method('GET', 'resource')
    response = method.add_response(200)
    repr = response.add_representation("application/xml", "xml")
    assert_equal "xml", repr.element
    assert_equal "application/xml", repr.media_type
    assert_equal response, repr.response
    assert_equal 1, response.representations.length
    assert_equal repr, response.representations.first
  end

  def test_request
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    method = res.add_method('GET', 'resource')
    request = method.add_request
    assert_equal method, request.method
    assert_equal 1, method.requests.length
    assert_equal request, method.requests.first
  end

  def test_parameter
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    method = res.add_method('GET', 'resource')
    request = method.add_request
    param = request.add_param("id", "query")
    assert_equal 'id', param.name
    assert_equal 'query', param.style
    assert_equal request, param.request
    assert_equal 1, request.parameters.length
    assert_equal param, request.parameters.first
  end


  def test_parameter_options
    base = "http://www.example.com/"
    path = "resources"
    app = Wadlgen::Application.new(base)
    res = app.add_resource(path)
    method = res.add_method('GET', 'resource')
    request = method.add_request
    param = request.add_param("id", "query")
    opt = param.add_option('xml', 'application/xml')
    assert_equal 'xml', opt.value
    assert_equal 'application/xml', opt.media_type
    assert_equal param, opt.parameter
    assert_equal 1, param.options.length
    assert_equal opt, param.options.first
  end

end