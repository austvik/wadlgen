require 'test/unit'
require 'wadlgen'

class TestClasses < Test::Unit::TestCase

  def test_merge_application
    app1 = Wadlgen::Application.new
    app1.add_doc('app1', "App1")
    gram1 = app1.add_grammars
    gram1.add_doc('doc1', 'Doc1')
    gram1.add_include("http://example.com/1")
    rt1 = app1.add_resource_type("res_type1")
    rt12 = app1.add_resource_type("res_type2")

    ress1 = app1.add_resources("http://base1/")
    res1 = ress1.add_resource 'GET', '/some/path1', 'id1', 'query'
    meth1 = res1.add_method 'GET', 'id1', 'href1'
    req1 = meth1.add_request
    param1 = req1.add_param 'id', 'query'
    repr1 = req1.add_representation 'application/json'
    resp1 = meth1.add_response '200'

    # Unique
    ress11 = app1.add_resources("http://baseX/")
    res11 = ress11.add_resource 'GET', '/some/pathX', 'idX', 'query'
    meth11 = res11.add_method 'GET', 'idX', 'hrefX'
    req11 = meth11.add_request
    param11 = req11.add_param 'id', 'query'
    repr11 = req11.add_representation 'application/json'
    resp11 = meth11.add_response '200'

    param1.add_option('xml', "application/xml")
    param1.add_option('json', "application/json")
    param1.add_link 'query', '1.0', '..'

    app2 = Wadlgen::Application.new
    app2.add_doc('app2', "App2")
    gram2 = app2.add_grammars
    gram2.add_doc('doc2', 'Doc2')
    gram2.add_include("http://example.net/2")
    rt2 = app2.add_resource_type('res_type2')
    rt23 = app2.add_resource_type('res_type3')
    ress2 = app2.add_resources("http://base2/")
    res2 = ress2.add_resource 'GET', '/some/path2', 'id2', 'query'
    res2.add_doc 'title', 'text'

    # Will collide
    ress21 = app2.add_resources("http://base1/")
    res21 = ress21.add_resource 'GET', '/some/path1', 'id1', 'query'
    res21.add_doc 'doc23', 'text2'
    res21.add_doc 'doc33', 'text3'
    meth21 = res21.add_method 'GET', 'id1', 'href1'
    meth22 = res21.add_method 'GET', 'id22', 'href22'
    req21 = meth21.add_request
    req22 = meth22.add_request
    param21 = req21.add_param 'id', 'query'
    repr21 = req21.add_representation 'application/json'
    resp21 = meth21.add_response '200'

    assert_equal 'app1', app1.docs.first.title
    assert_equal 'app2', app2.docs.first.title

    merge = Wadlgen::Wadl.merge app1, app2

    assert_equal 'app1', app1.docs.first.title
    assert_equal 'app2', app2.docs.first.title
    assert_equal 'app1', merge.docs.first.title

    assert_equal 'http://base1/', merge.resources.first.base
    assert_equal 'http://base2/', merge.resources.last.base

    #puts Wadlgen::Wadl.generate_wadl app1
    #puts Wadlgen::Wadl.generate_wadl app2
    #puts Wadlgen::Wadl.generate_wadl merge

    assert_equal '/some/path1', merge.resources.first.resources.first.path
    assert_equal '/some/path2', merge.resources.last.resources.first.path

    assert_equal '200', merge.resources.first.resources.first.methods.first.responses.first.status
    assert_equal 'id', merge.resources.first.resources.first.methods.first.request.params.first.name
    assert_equal 'xml', merge.resources.first.resources.first.methods.first.request.params.first.options.first.value
    assert_equal 'query', merge.resources.first.resources.first.methods.first.request.params.first.link.resource_type
  end

end

