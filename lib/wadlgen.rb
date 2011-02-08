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

      resources = xml.xpath('/wadl:application/wadl:resources', ns).first
      base = resources['base']
      app = Wadlgen::Application.new(base)
      resources.xpath('wadl:resource', ns).each do |resource|
        resource_elem = app.add_resource(resource['path'])
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

      app = Wadlgen::Application.new(base)
      Rails.application.routes.named_routes.each do |name, route|
        defaults = route.defaults

        controller = defaults[:controller]
        action = defaults[:action]

        next if controller.match /\//
        next if action == 'edit'

        resource = app.get_resource(route.path)
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
        xml.resources('base' => application.base) do
          application.resources.each do |resource|
            xml.resource('path' => resource.path) do
              resource.methods.each do |method|
                xml.tag!('method', 'name' => method.verb, 'id' => method.id) do
                  method.requests.each do |req|
                    xml.request do
                      req.parameters.each do |param|
                        xml.param('name' => param.name, 'style' => param.style) do
                          param.options.each do |opt|
                            xml.option('value' => opt.value, 'mediaType' => opt.media_type)
                          end
                        end
                      end
                    end
                  end
                  method.responses.each do |resp|
                    xml.response('status' => resp.status) do
                      resp.representations.each do |repr|
                        if repr.element.nil?
                          xml.representation('mediaType' => repr.media_type)
                        else
                          xml.representation('mediaType' => repr.media_type, 'element' => repr.element)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      out
    end

private

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