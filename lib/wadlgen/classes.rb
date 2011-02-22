
module Wadlgen

  #
  # Include this module in classes that can have doc tags
  #
  module Documentable

    attr_accessor :docs

    def add_doc(title, text, xml_lang = nil)
      doc = Doc.new(self, title, text, xml_lang)
      self.docs = [] unless self.docs
      self.docs << doc
      doc
    end

    def has_doc?(title)
      self.docs = [] if self.docs.nil?
      self.docs.any? {|doc| doc.title == title}
    end

  end

  #
  # Include this module in classes that can have resource tags
  #
  module Resourceable

    attr_accessor :resources

    def add_resource(type = nil, path = nil, id = nil, query_type = nil)
      res = Resource.new(self, type, path, id, query_type)
      res.path = path
      self.resources = [] if self.resources.nil?
      self.resources << res
      res
    end

    def has_resource?(type, path)
      self.resources = [] if self.resources.nil?
      self.resources.any? {|resource| resource.path == path && resource.type == type}
    end

    def get_resource(type, path)
      if has_resource? type, path
        self.resources.find {|resource| resource.path == path && resource.type == type}
      else
        add_resource type, path
      end
    end

  end

  #
  # Include this module in classes that can have param tags
  #
  module Paramable

    attr_accessor :params

    def add_param(name, style, href = nil, id = nil, type = nil, default = nil, path = nil, required = nil, repeating = nil, fixed = nil)
      param = Parameter.new(self, name, style, href, id, type, default, path, required, repeating, fixed)
      self.params = [] unless self.params
      self.params << param
      param
    end

    def has_param?(name, style)
      self.params = [] unless self.params
      self.params.any? {|param| param.name == name && param.style == style}
    end

    def get_param(name, style, href = nil, id = nil, type = nil, default = nil, path = nil, required = nil, repeating = nil, fixed = nil)
      if has_param? name, style
        self.params.find {|param| param.name == name && param.style == style}
      else
        add_param name, style, href, id, type, default, path, required, repeating, fixed
      end
    end

  end

  #
  # Include this module in classes that can have method tags
  #
  module Methodable

    attr_accessor :methods

    def add_method(name, id, href = nil)
      method = Method.new(self, name, id, href)
      self.methods = [] unless self.methods
      self.methods << method
      method
    end

    def has_method?(name, id)
      self.methods = [] unless self.methods
      self.methods.any? {|method| method.name == name && method.id == id}
    end

    def get_method(name, id)
      if has_method? name, id
        self.methods.find {|method| method.name == name && method.id == id}
      else
        add_method name, id
      end
    end

  end

  #
  # Define in elements that has links
  #
  module Linkable

    attr_accessor :link

    def add_link(resource_type, rev = nil, rel = nil)
      self.link = Link.new(self, resource_type, rev, rel)
    end

    def has_link?(resource_type)
      if self.link
        self.link.resource_type == resource_type
      end
    end

    def get_link(resource_type, rev = nil, rel = nil)
      if has_link? resorce_type
        self.links
      else
        add_link resource_type, rev, rel
      end
    end

  end

  #
  # Define in elements that has options
  #
  module Optionable

    attr_accessor :options

    def add_option(value, media_type = nil)
      option = ParameterOption.new(self, value, media_type)
      self.options = [] unless self.options
      self.options << option
      option
    end

    def has_option?(value)
      self.options = [] unless self.options
      self.options.any? {|opt| opt.value == value}
    end

    def get_option(value, media_type = nil)
      if has_option? value
        self.options.find {|opt| opt.value == value and opt.media_type == media_type}
      else
        add_option value, media_type
      end
    end

  end

  #
  # Include this module in classes that can have representation tags
  #
  module Representable

    attr_accessor :representations

    def add_representation(media_type, element = nil, href = nil, id = nil, profile = nil)
      repr = Representation.new(self, media_type, element, href, id, profile)
      self.representations ||= []
      self.representations << repr
      repr
    end

    def has_representation?(media_type)
      self.representations ||= []
      self.representations.any? {|repr| repr.media_type == media_type}
    end

    def get_representation(media_type, element = nil)
      if has_representation? media_type
        self.representations.find {|repr| repr.media_type == media_type}
      else
        add_representation media_type, element
      end
    end

  end

  class Application

    include Wadlgen::Documentable

    attr_accessor :resources, :grammars, :resource_types

    def initialize()
      self.resources = []
      self.resource_types = []
    end

    def add_grammars
      g = Grammars.new(self)
      self.grammars = g
      g
    end

    def add_resources(base)
      ress = Resources.new(self, base)
      self.resources << ress
      ress
    end

    def has_resources?(base)
      self.resources.any? {|res| res.base == base}
    end

    def get_resources(base)
      if has_resources? base
        self.resources.find {|res| res.base == base}
      else
        add_resources base
      end
    end

    def add_resource_type(id)
      rt = ResourceType.new(self, id)
      self.resource_types << rt
      rt
    end

  end

  class Doc
    attr_accessor :parent, :title, :text, :xml_lang

    def initialize(parent, title, text, xml_lang = nil)
      self.parent = parent
      self.title = title
      self.text = text
      self.xml_lang = xml_lang
    end

  end

  class Grammars

    include Wadlgen::Documentable

    attr_accessor :includes, :application

    def initialize(application)
      self.application = application
      self.includes = []
    end

    def add_include(href)
      incl = Wadlgen::Incl.new(self, href)
      includes << incl
      incl
    end

    def has_include?(href)
      self.includes.any? {|incl| incl.href == href}
    end

  end

  class Incl

    include Wadlgen::Documentable

    attr_accessor :grammars, :href

    def initialize(grammars, href)
      self.grammars = grammars
      self.href = href
    end

  end

  class Resources

    include Wadlgen::Documentable
    include Wadlgen::Resourceable

    attr_accessor :parent, :base

    def initialize(parent, base)
      self.parent = parent
      self.base = base
    end

  end

  class ResourceType

    include Wadlgen::Documentable
    include Wadlgen::Resourceable
    include Wadlgen::Methodable
    include Wadlgen::Paramable

    attr_accessor :id, :application

    def initialize(application, id)
      self.application = application
      self.id = id
    end

  end

  class Resource

    include Wadlgen::Documentable
    include Wadlgen::Resourceable
    include Wadlgen::Methodable
    include Wadlgen::Paramable

    attr_accessor :type, :path, :id, :query_type, :parent

    def initialize(parent, type = nil, path = nil, id = nil, query_type = nil)
      self.parent = parent
      self.type = type
      self.path = path
      self.id = id
      self.query_type = query_type
    end

  end

  class Method

    include Wadlgen::Documentable

    attr_accessor :parent, :name, :id, :href, :responses, :request

    def initialize(parent, name = nil, id = nil, href = nil)
      self.responses = []
      self.request = nil
      self.parent = parent
      self.name = name
      self.href = href
      self.id = id
    end

    def add_response(status)
      resp = Response.new(self, status)
      self.responses << resp
      resp
    end

    def add_request()
      self.request = Request.new(self)
    end

  end

  class Response

    include Wadlgen::Documentable
    include Wadlgen::Representable
    include Wadlgen::Paramable

    attr_accessor :method, :status

    def initialize(method, status)
      self.method = method
      self.status = status
    end

  end

  class Representation

    include Wadlgen::Documentable
    include Wadlgen::Paramable

    attr_accessor :element, :media_type, :parent, :href, :id, :profile

    def initialize(parent, media_type = nil, element = nil, href = nil, id = nil, profile = nil)
      self.parent = parent
      self.element = element
      self.media_type = media_type
      self.href = href
      self.id = id
      self.profile = profile
    end

  end

  class Request

    include Wadlgen::Documentable
    include Wadlgen::Paramable
    include Wadlgen::Representable

    attr_accessor :method

    def initialize(method)
      self.method = method
    end

  end

  class Parameter

    include Wadlgen::Documentable
    include Wadlgen::Linkable
    include Wadlgen::Optionable

    attr_accessor :parent, :name, :style, :options, :href, :link, :id, :type, :default, :path, :required, :repeating, :fixed

    def initialize(parent, name, style, href = nil, id = nil, type = nil, default = nil, path = nil, required = nil, repeating = nil, fixed = nil)
      self.parent = parent
      self.name = name
      self.style = style
      self.href = href
      self.id = id
      self.type = type
      self.default = default
      self.path = path
      self.required = required
      self.repeating = repeating
      self.fixed = fixed
      self.options = []
    end

  end

  class Link
    attr_accessor :parameter, :resource_type, :rev, :rel

    include Wadlgen::Documentable
    
    def initialize(parameter, resource_type = nil, rev = nil, rel = nil)
      self.parameter = parameter
      self.resource_type = resource_type
      self.rev = rev
      self.rel = rel
    end
  end

  class ParameterOption
    
    include Wadlgen::Documentable

    attr_accessor :parameter, :value, :media_type

    def initialize(parameter, value, media_type = nil)
      self.parameter = parameter
      self.value = value
      self.media_type = media_type
      self.docs = []
    end

  end

end