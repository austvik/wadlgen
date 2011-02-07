
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

    def has_resource?(path)
      self.resources.any?{|res| res.path == path}
    end

    def get_resource(path)
      if has_resource? path
        self.resources.find {|resource| resource.path == path}
      else
        add_resource path
      end
    end
  end

  class Resource
    attr_accessor :methods, :path, :application

    def initialize(application)
      self.application = application
      self.methods = []
    end

    def add_method(verb, action)
      method = Method.new(self, verb, action)
      self.methods << method
      method
    end
    
    def has_method?(verb, action)
      self.methods.any?{|method| method.verb == verb && method.action == action}
    end

    def get_method(verb, action)
      if has_method? verb, action
        self.methods.find {|method| method.verb == verb && method.action == action}
      else
        add_method verb, action
      end
    end

  end

  class Method
    attr_accessor :resource, :verb, :action, :responses, :requests

    def initialize(resource, verb, action)
      self.responses = []
      self.requests = []
      self.resource = resource
      self.verb = verb
      self.action = action
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