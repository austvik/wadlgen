
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

    def add_response(data = {})
      resp = Response.new(self)
      self.responses << resp
      resp
    end
  end

  class Response
    attr_accessor :format, :method

    def initialize(method, data = {})
      selv.method = method
      data.each do |pair|
        name = pair.first
        name = name.to_s + "="
        name = name.to_sym
        value = pair.last
        self.send name, value
      end
    end
  end

  class Request
    attr_accessor :params, :method

    def initialize(method)
      selv.method = method
    end
  end

  class Parameter
    attr_accessor :request

    def initialize(request)
      self.request = request
    end
  end

end