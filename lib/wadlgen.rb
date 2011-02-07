module Wadlgen

  require "wadlgen/railtie.rb" if defined?(Rails)
  require "wadlgen/classes"

  class Wadl

    def generate(base)
      application = get_route_structure(base)
      puts generate_wadl application
    end

    def get_route_structure(base)
      Rails.application.reload_routes!
      structure = {}
      Rails.application.routes.named_routes.each do |name, route|
        defaults = route.defaults

        controller = defaults[:controller]

        next if controller.match /\//

        structure[controller] = {:methods => []} unless structure.has_key? controller
        structure[controller][:methods] << {
          :verb => route.verb,
          :action => defaults[:action],
          :path => route.path
        }

      end
      structure
    end

    def generate_wadl(application)
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

  end

end