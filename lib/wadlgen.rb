module Wadlgen

  require "wadlgen/railtie.rb" if defined?(Rails)
  require "wadlgen/classes"
  require "wadlgen/xml_parser"
  require "wadlgen/route_parser"
  require "wadlgen/xml_generator"
  require 'nokogiri'

  class Wadl

    def self.generate(base)
      application = parse_route(base)
      puts generate_wadl application
    end

    def self.parse_xml(xml_doc)
      parser = Wadlgen::XMLParser.new xml_doc
      parser.parse
    end

    def self.parse_route(base)
      parser = Wadlgen::RouteParser.new base
      parser.parse
    end

    def self.generate_wadl(application)
      generator = Wadlgen::XMLGenerator.new application
      generator.generate
    end

  end

end