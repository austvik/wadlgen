module Wadlgen

  require "wadlgen/railtie.rb" if defined?(Rails)

  class Wadl

    def generate(base)
      structure = get_route_structure
      puts generate_wadl base, structure
    end

    def get_route_structure
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

    def generate_wadl(base, structure)
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
        xml.resources('base' => base) do
          structure.each_pair do |controller_name, methods|
            xml.resource('path' => controller_name) do
              methods.each do |method_name|
                xml.tag!('method', 'name' => method_name, 'id' => "#{method_name}_#{controller_name}") do
                  xml.request
                  xml.response
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