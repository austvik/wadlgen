module Wadlgen

  require "wadlgen/railtie.rb" if defined?(Rails)
  require "wadlgen/classes"
  require "wadlgen/xml_parser"
  require "wadlgen/route_parser"
  require "wadlgen/xml_generator"
  require "wadlgen/merge"
  require 'nokogiri'

  class Wadl

    #
    # Generate a WADL XML document based on a Rails application
    # and base.
    #
    def self.generate(application, base)
      application = parse_route(application, base)
      generate_wadl application
    end

    #
    # parses a given XML string, and generates a Wadlgen::Application
    # object from it.
    #
    def self.parse_xml(xml_doc)
      parser = Wadlgen::XMLParser.new xml_doc
      parser.parse
    end

    #
    # Parses routes from Rails 3, and generates a Wadlgen::Application
    # object from it.
    #
    def self.parse_route(application, base)
      parser = Wadlgen::RouteParser.new application, base
      parser.parse
    end

    #
    # Generates a WADL XML string based on a Wadlgen::Application object
    #
    def self.generate_wadl(application)
      generator = Wadlgen::XMLGenerator.new application
      generator.generate
    end

    #
    # Merges two Wadlgen::Application objects and returns the result
    # as another Wadlgen::Application object.
    #
    def self.merge(initial_application, additional_application)
      merger = Wadlgen::Merge.new initial_application, additional_application
      merger.merge
    end

  end

end