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

      ns = {'wadl' => 'http://wadl.dev.java.net/2009/02'}

      app = Wadlgen::Application.new
      xml.xpath('/wadl:application/wadl:doc', ns).each do |docs|
        app.add_doc(docs['title'], docs.content)
      end
      resources = xml.xpath('/wadl:application/wadl:resources', ns).first
      base = resources['base']
      ress = app.add_resources(base)
      resources.xpath('wadl:resource', ns).each do |resource|
        resource_elem = ress.add_resource(nil, resource['path'])
        resource.xpath('wadl:method', ns).each do |method|
          method_elem = resource_elem.add_method(method['name'], method['id'])
          method.xpath('wadl:request', ns).each do |request|
            request_elem = method_elem.add_request
            request.xpath('wadl:param', ns).each do |param|
              param_elem = request_elem.add_param(param['name'], param['style'])
              param.xpath('wadl:option', ns).each do |option|
                param_elem.add_option(option['value'], option['mediaType'])
              end
            end
          end
          method.xpath('wadl:response', ns).each do |response|
            response_elem = method_elem.add_response(response['status'].to_i)
            response.xpath('wadl:representation', ns).each do |repr|
              response_elem.add_representation(repr['mediaType'], repr['element'])
            end
          end
        end
      end
      app
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
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' => "http://wadl.dev.java.net/2009/02 wadl.xsd",
        'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema",
        'xmlns' => "http://wadl.dev.java.net/2009/02"
      }

      xml.application(namespaces) do
        add_docs xml, application
        xml.resources('base' => application.resources.base) do
          add_resources xml, application.resources
        end
      end
      out
    end

private

    def self.add_resources(xml, elem)
      if elem.resources
        elem.resources.each do |resource|
          xml.resource('path' => resource.path) do
            add_docs xml, resource
            add_params xml, resource
            add_methods xml, resource.methods
            add_resources xml, resource
          end
        end
      end
    end

    def self.add_methods(xml, methods)
      if methods
        methods.each do |method|
          xml.tag!('method', 'name' => method.name, 'id' => method.id) do
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
          attrs = {'mediaType' => repr.media_type}
          attrs['element'] = repr.element if repr.element
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
          attrs = {'name' => param_elem.name, 'style' => param_elem.style}
          atttrs['href'] = param_elem.href unless param_elem.href.nil?
          atttrs['id'] = param_elem.id unless param_elem.id.nil?
          atttrs['type'] = param_elem.type unless param_elem.type.nil?
          atttrs['required'] = param_elem.required unless param_elem.required.nil?
          atttrs['default'] = param_elem.default unless param_elem.default.nil?
          atttrs['path'] = param_elem.path unless param_elem.path.nil?
          atttrs['repeating'] = param_elem.repeating unless param_elem.repeating.nil?
          atttrs['fixed'] = param_elem.fixed unless param_elem.fixed.nil?
          xml.param(attrs) do
            add_docs xml, param_elem
            if param_elem.options
              param_elem.options.each do |opt_elem|
                if opt_elem.docs and opt_elem.docs.length > 0
                  xml.option('value' => opt_elem.value, 'mediaType' => opt_elem.media_type) do
                    add_docs xml, opt_elem
                  end
                else
                  xml.option('value' => opt_elem.value, 'mediaType' => opt_elem.media_type)
                end
              end
            end
          end
        end
      end
    end

    def self.add_docs(xml, elem)
      if elem.docs
        elem.docs.each do |docs_elem|
          xml.doc(docs_elem.text, 'title' => docs_elem.title)
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