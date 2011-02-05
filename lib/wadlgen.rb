module Wadlgen

  require "wadlgen/railtie.rb" if defined?(Rails)

  class Wadl

    def generate
      structure = get_route_structure
      puts generate_wadl structure
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

    def generate_wadl(structure)
      require 'builder'

      out = ""
      xml =  Builder::XmlMarkup.new :indent => 2, :target => out
      xml.instruct!

      xml.application do
        xml.resources do
          structure.each_pair do |controller_name, methods|
            xml.resource('path' => '') do
              xml.name(controller_name)
              xml.tag! 'method' do
                xml.request
                xml.responce
              end
            end
          end
        end
      end
      out
    end

  end

end