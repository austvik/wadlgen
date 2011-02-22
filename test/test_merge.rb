require 'test/unit'
require 'wadlgen'

class TestClasses < Test::Unit::TestCase

  def test_merge_application
    app1 = Wadlgen::Application.new
    app1.add_doc('app1', "App1")
    gram1 = app1.add_grammars
    gram1.add_doc('doc1', 'Doc1')
    gram1.add_include("http://example.com/1")

    app2 = Wadlgen::Application.new
    app2.add_doc('app2', "App2")
    gram2 = app2.add_grammars
    gram2.add_doc('doc2', 'Doc2')
    gram2.add_include("http://example.net/2")

    assert_equal 'app1', app1.docs.first.title
    assert_equal 'app2', app2.docs.first.title

    merge = Wadlgen::Wadl.merge app1, app2

    assert_equal 'app1', app1.docs.first.title
    assert_equal 'app2', app2.docs.first.title
    assert_equal 'app1', merge.docs.first.title

  end

end

