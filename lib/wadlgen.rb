module Wadlgen

  require "wadlgen/railtie.rb" if defined?(Rails)
  require "wadlgen/classes"
  require "wadlgen/merge"
  require "wadlgen/xml_parser"
  require "wadlgen/route_parser"
  require "wadlgen/xml_generator"
  require 'nokogiri'

  class Wadl

    def self.generate(application, base)
      application = parse_route(application, base)
      generate_wadl application
    end

    def self.parse_xml(xml_doc)
      parser = Wadlgen::XMLParser.new xml_doc
      parser.parse
    end

    def self.parse_route(application, base)
      parser = Wadlgen::RouteParser.new application, base
      parser.parse
    end

    def self.generate_wadl(application)
      generator = Wadlgen::XMLGenerator.new application
      generator.generate
    end

    def self.merge(initial_application, additional_application)
      merger = Wadlgen::Merge.new initial_application, additional_application
      merger.merge
    end

  end

end