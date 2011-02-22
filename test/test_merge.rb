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
    ress1 = app1.add_resources("http://base1/")
    res1 = ress1.add_resource 'GET', '/some/path1', 'id1', 'query'
    meth1 = res1.add_method 'GET', 'id1', 'href1'
    req1 = meth1.add_request
    param1 = req1.add_param 'id', 'query'
    repr1 = req1.add_representation 'application/json'
    resp1 = meth1.add_response '200'

    app2 = Wadlgen::Application.new
    app2.add_doc('app2', "App2")
    gram2 = app2.add_grammars
    gram2.add_doc('doc2', 'Doc2')
    gram2.add_include("http://example.net/2")
    rt2 = app2.add_resource_type('res_type2')
    ress2 = app2.add_resources("http://base2/")
    res2 = ress2.add_resource 'GET', '/some/path2', 'id2', 'query'

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
  end

end

