module Wadlgen

  require "wadlgen/railtie.rb" if defined?(Rails)
  require "wadlgen/classes"
  require 'nokogiri'

  class Wadl

    def self.generate(base)
      application = get_route_structure(base)
      puts generate_wadl application
    end

    def self.parse(xml_doc)
      xml = Nokogiri::XML::parse(xml_doc)

      ns = {
        'wadl' => 'http://wadl.dev.java.net/2009/02',
        'xml' => 'http://www.w3.org/XML/1998/namespace'
      }

      app_elem = Wadlgen::Application.new
      app = xml.xpath('//wadl:application', ns).first
      
      parse_docs(app, app_elem, 'wadl:doc', ns)
      parse_grammars(app, app_elem, ns)

      resources = app.xpath('wadl:resources', ns).first
      base = resources['base']
      resources_elem = app_elem.add_resources(base)
      parse_docs(resources, resources_elem, 'wadl:doc', ns)
      resources.xpath('wadl:resource', ns).each do |resource|
        resource_elem = resources_elem.add_resource(resource['type'], resource['path'], resource['id'], resource['queryType'])
        parse_docs(resource, resource_elem, 'wadl:doc', ns)
        parse_params resource, resource_elem, ns
        parse_methods resource, resource_elem, ns
      end
      app.xpath('wadl:resource_type', ns).each do |resource_type|
        resource_type_elem = app_elem.add_resource_type(resource_type['id'])
        parse_docs resource_type, resource_type_elem, 'wadl:doc', ns
        parse_params resource_type, resource_type_elem, ns
        parse_methods resource_type, resource_type_elem, ns
      end
      app_elem
    end

    def self.get_route_structure(base)
      Rails.application.reload_routes!

      app = Wadlgen::Application.new
      ress = app.add_resources(base)
      Rails.application.routes.named_routes.each do |name, route|
        defaults = route.defaults

        controller = defaults[:controller]
        action = defaults[:action]

        next if controller.match /\//
        next if action == 'edit'

        resource = ress.get_resource(nil, route.path)
        method = resource.get_method(route.verb, defaults[:action])
        
        req = method.add_request

        query = req.add_param('format', 'query')
        success = method.add_response(200)
        get_representations(controller, action).each_pair do |format, element|
          success.add_representation "application/#{format}", element
          query.add_option(format, "application/#{format}")
        end

        get_params(action).each_pair do |param, type|
          req.add_param(param, type)
        end
      end
      app
    end

    def self.generate_wadl(application)
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

private

    def self.parse_grammars(parent, parent_elem, ns)
      parent.xpath("wadl:grammars", ns).each do |grammars|
        grammars_elem = parent_elem.add_grammars
        parse_docs(grammars, grammars_elem, 'wadl:doc', ns)
        parse_include(grammars, grammars_elem, ns)
      end
    end

    def self.parse_include(parent, parent_elem, ns)
      parent.xpath("wadl:include", ns).each do |include|
        include_elem = parent_elem.add_include(include['href'])
        parse_docs(include, include_elem, 'wadl:doc', ns)
      end
    end

    def self.parse_docs(xml, obj, xpath, ns)
      xml.xpath(xpath, ns).each do |docs|
        obj.add_doc(docs['title'], docs.content, docs['lang'])
      end      
    end

    def self.parse_params(parent, parent_elem, ns)
      parent.xpath('wadl:param', ns).each do |param|
        param_elem = parent_elem.add_param(param['name'], param['style'], param['href'], param['id'], param['type'], param['default'], param['path'], param['required'], param['repeating'], param['fixed'])
        parse_docs param, param_elem, 'wadl:doc', ns
        param.xpath('wadl:option', ns).each do |option|
          option_elem = param_elem.add_option(option['value'], option['mediaType'])
          parse_docs option, option_elem, 'wadl:doc', ns
        end
        param.xpath('wadl:link', ns).each do |link|
          link_elem = param_elem.add_link(link['resource_type'], link['rev'], link['rel'])
          parse_docs link, link_elem, 'wadl:doc', ns
        end
      end
    end

    def self.parse_representation(parent, parent_elem, ns)
      parent.xpath('wadl:representation', ns).each do |repr|
        repr_elem = parent_elem.add_representation(repr['mediaType'], repr['element'], repr['href'], repr['id'], repr['profile'])
        parse_docs(repr, repr_elem, 'wadl:doc', ns)
        parse_params repr, repr_elem, ns
      end
    end

    def self.parse_methods(parent, parent_elem, ns)
        parent.xpath('wadl:method', ns).each do |method|
          method_elem = parent_elem.add_method(method['name'], method['id'], method['href'])
          parse_docs(method, method_elem, 'wadl:doc', ns)
          method.xpath('wadl:request', ns).each do |request|
            request_elem = method_elem.add_request
            parse_docs(request, request_elem, 'wadl:doc', ns)
            parse_params request, request_elem, ns
            parse_representation request, request_elem, ns
          end
          method.xpath('wadl:response', ns).each do |response|
            response_elem = method_elem.add_response(response['status'])
            parse_docs(response, response_elem, 'wadl:doc', ns)
            parse_params response, response_elem, ns
            parse_representation response, response_elem, ns
          end
        end
    end

    def self.add_resources(xml, elem)
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

    def self.add_grammars(xml, application)
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

    def self.add_resource_types(xml, application)
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

    def self.add_methods(xml, methods)
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

    def self.add_request(xml, request)
      if request
        xml.request do
          add_docs xml, request
          add_params xml, request
          add_representation xml, request.representations
        end
      end
    end

    def self.add_responses(xml, responses)
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

    def self.add_representation(xml, representations)
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

    def self.add_params(xml, elem)
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

    def self.add_docs(xml, elem)
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

    def self.get_representations(controller, action)
      if action == 'edit'
        {:html => 'html'}
      else
        res = {}
        controller_name = "#{controller}_controller".camelcase
        cont_obj = Object::const_get(controller_name).new()
        cont_obj.mimes_for_respond_to.each_pair do |format, type|
          res[format] = format
          # TODO: Only and Except
        end
        res
      end
    end

    def self.get_params(action)
      case action
      when 'show'
        {:id => 'query'}
      when 'new'
        {:id => 'query'}
      when 'create'
        {:id => 'query'}
      when 'update'
        {:id => 'query'}
      when 'destroy'
        {:id => 'query'}
      when 'index'
        {}
      when 'edit'
        {}
      else
        {}
      end
    end

  end # class Wadl

end