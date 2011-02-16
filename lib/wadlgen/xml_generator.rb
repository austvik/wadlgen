module Wadlgen

  class XMLGenerator

    attr_accessor :application

    def initialize(application)
      self.application = application
    end
    
    def generate
      generate_wadl self.application
    end

  private

    def generate_wadl(application)
      require 'builder'

      out = ""
      xml =  Builder::XmlMarkup.new :indent => 2, :target => out
      xml.instruct!

      namespaces = {
        'xmlns' => "http://wadl.dev.java.net/2009/02",
        'xmlns:xml' => "http://www.w3.org/XML/1998/namespace" ,
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' => "http://wadl.dev.java.net/2009/02 wadl.xsd",
        'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema"
      }

      xml.application(namespaces) do
        add_docs xml, application
        add_grammars xml, application
        xml.resources('base' => application.resources.base) do
          add_docs(xml, application.resources)
          add_resources xml, application.resources
        end
        add_resource_types xml, application
      end
      out
    end

    def add_resources(xml, elem)
      if elem.resources
        elem.resources.each do |resource|
          rattrs = {}
          rattrs['id'] = resource.id if resource.id
          rattrs['path'] = resource.path if resource.path
          rattrs['queryType'] = resource.query_type if resource.query_type
          rattrs['type'] = resource.type if resource.type
          xml.resource(rattrs) do
            add_docs xml, resource
            add_params xml, resource
            add_methods xml, resource.methods
            add_resources xml, resource
          end
        end
      end
    end

    def add_grammars(xml, application)
      if application.grammars
        xml.grammars do
          add_docs xml, application.grammars
          application.grammars.includes.each do |incl|
            if incl.docs
              xml.include :href => incl.href do
                add_docs xml, incl
              end
            else
              xml.include :href => incl.href
            end
          end
        end
      end
    end

    def add_resource_types(xml, application)
      if application.resource_types
        application.resource_types.each do |rt|
          xml.resource_type :id => rt.id do
            add_docs xml, rt
            add_params xml, rt
            add_methods xml, rt.methods
          end
        end
      end
    end

    def add_methods(xml, methods)
      if methods
        methods.each do |method|
          margs = {}
          margs['href'] = method.href if method.href
          margs['id'] = method.id if method.id
          margs['name'] = method.name if method.name
          xml.tag!('method', margs) do
            add_docs xml, method
            add_request xml, method.request
            add_responses xml, method.responses
          end
        end
      end
    end

    def add_request(xml, request)
      if request
        xml.request do
          add_docs xml, request
          add_params xml, request
          add_representation xml, request.representations
        end
      end
    end

    def add_responses(xml, responses)
      if responses
        responses.each do |resp|
          xml.response('status' => resp.status) do
            add_docs xml, resp
            add_params xml, resp
            add_representation xml, resp.representations
          end
        end
      end
    end

    def add_representation(xml, representations)
      if representations
        representations.each do |repr|
          attrs = {}
          attrs['element'] = repr.element if repr.element
          attrs['href'] = repr.href if repr.href
          attrs['id'] = repr.id if repr.id
          attrs['mediaType'] = repr.media_type if repr.media_type
          attrs['profile'] = repr.profile if repr.profile

          if repr.docs || repr.params
            xml.representation(attrs) do
              add_docs xml, repr
              add_params xml, repr
            end
          else
            xml.representation(attrs)
          end
        end
      end
    end

    def add_params(xml, elem)
      if elem.params
        elem.params.each do |param_elem|
          attrs = {}
          attrs['default'] = param_elem.default unless param_elem.default.nil?
          attrs['fixed'] = param_elem.fixed unless param_elem.fixed.nil?
          attrs['href'] = param_elem.href unless param_elem.href.nil?
          attrs['id'] = param_elem.id unless param_elem.id.nil?
          attrs['name'] = param_elem.name unless param_elem.name.nil?
          attrs['path'] = param_elem.path unless param_elem.path.nil?
          attrs['repeating'] = param_elem.repeating unless param_elem.repeating.nil?
          attrs['required'] = param_elem.required unless param_elem.required.nil?
          attrs['style'] = param_elem.style unless param_elem.style.nil?
          attrs['type'] = param_elem.type unless param_elem.type.nil?
          xml.param(attrs) do
            add_docs xml, param_elem
            if param_elem.options
              param_elem.options.each do |opt_elem|
                if opt_elem.docs and opt_elem.docs.length > 0
                  xml.option('mediaType' => opt_elem.media_type, 'value' => opt_elem.value) do
                    add_docs xml, opt_elem
                  end
                else
                  xml.option('mediaType' => opt_elem.media_type, 'value' => opt_elem.value)
                end
              end
            end
            if param_elem.link
              link_elem = param_elem.link
              if link_elem.docs and link_elem.docs.length > 0
                xml.link('rel' => link_elem.rel, 'resource_type' => link_elem.resource_type, 'rev' => link_elem.rev) do
                  add_docs xml, link_elem
                end
              else
                xml.link('rel' => link_elem.rel, 'resource_type' => link_elem.resource_type, 'rev' => link_elem.rev)
              end
            end
          end
        end
      end
    end

    def add_docs(xml, elem)
      if elem.docs
        elem.docs.each do |docs_elem|
          attrs = {}
          attrs['title'] = docs_elem.title if docs_elem.title
          attrs['xml:lang'] = docs_elem.xml_lang if docs_elem.xml_lang
          if docs_elem.text == ''
            xml.doc attrs
          else
            xml.doc docs_elem.text, attrs
          end
        end
      end
    end

  end
end