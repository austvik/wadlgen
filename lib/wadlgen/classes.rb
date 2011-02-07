
module Wadlgen

  class Application
    attr_accessor :base, :resources

    def initialize(base)
      self.base = base
      self.resources = []
    end

    def add_resource(path)
      res = Resource.new(self)
      res.path = path
      resources << res
      res
    end
  end

  class Resource
    attr_accessor :methods, :path, :application

    def initialize(application)
      self.application = application
      self.methods = []
    end

    def add_method(data = {})
      method = Method.new(self, data)
      self.methods << method
      method
    end
  end

  class Method
    attr_accessor :resource, :verb, :action, :responses, :requests

    def initialize(resource, data = {})
      self.responses = []
      self.requests = []
      self.resource = resource
      data.each do |pair|
        name = pair.first
        name = name.to_s + "="
        name = name.to_sym
        value = pair.last
        self.send name, value
      end
    end

    def id
      "#{verb}_#{resource.path}"
    end

    def add_response(status)
      resp = Response.new(self, status)
      self.responses << resp
      resp
    end

    def add_request()
      request = Request.new(self)
      self.requests << request
      request
    end
  end

  class Response
    attr_accessor :status, :method, :representations

    def initialize(method, status)
      self.method = method
      self.status = status
      self.representations = []
    end

    def add_representation(media_type, element = nil)
      repr = Representation.new(self, media_type, element)
      self.representations << repr
      repr
    end
  end

  class Representation
    attr_accessor :element, :media_type, :response

    def initialize(response, media_type, element = nil)
      self.response = response
      self.element = element
      self.media_type = media_type
    end
  end

  class Request
    attr_accessor :method, :parameters

    def initialize(method)
      self.parameters = []
      self.method = method
    end

    def add_param(name, style)
      param = Parameter.new(self, name, style)
      self.parameters << param
      param
    end
  end

  class Parameter
    attr_accessor :request, :name, :style, :options

    def initialize(request, name, style)
      self.request = request
      self.name = name
      self.style = style
      self.options = []
    end

    def add_option(value, media_type)
      option = ParameterOption.new(self, value, media_type)
      options << option
      option
    end
  end

  class ParameterOption
    attr_accessor :parameter, :value, :media_type

    def initialize(parameter, value, media_type)
      self.parameter = parameter
      self.value = value
      self.media_type = media_type
    end
  end

end