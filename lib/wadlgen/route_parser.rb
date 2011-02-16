module Wadlgen

  class RouteParser

    attr_accessor :base

    def initialize(base)
      self.base = base
    end

    def parse
      get_route_structure base
    end

  private

    def get_route_structure(base)
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

    def get_representations(controller, action)
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

    def get_params(action)
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

  end

end