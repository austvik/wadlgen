module Wadlgen

  class XMLParser
    
    attr_accessor :xml_doc
    
    def initialize(xml_doc)
      self.xml_doc = xml_doc
    end

    def parse()
      parse_application(self.xml_doc)
    end

  private

    def parse_application(doc)
      xml = Nokogiri::XML::parse(doc)

      ns = {
        'wadl' => 'http://wadl.dev.java.net/2009/02',
        'xml' => 'http://www.w3.org/XML/1998/namespace'
      }

      app_elem = Wadlgen::Application.new
      app = xml.xpath('//wadl:application', ns).first

      parse_docs(app, app_elem, ns)
      parse_grammars(app, app_elem, ns)

      resources = app.xpath('wadl:resources', ns).first
      base = resources['base']
      resources_elem = app_elem.add_resources(base)
      parse_docs(resources, resources_elem, ns)
      resources.xpath('wadl:resource', ns).each do |resource|
        resource_elem = resources_elem.add_resource(resource['type'], resource['path'], resource['id'], resource['queryType'])
        parse_docs(resource, resource_elem, ns)
        parse_params resource, resource_elem, ns
        parse_methods resource, resource_elem, ns
      end
      app.xpath('wadl:resource_type', ns).each do |resource_type|
        resource_type_elem = app_elem.add_resource_type(resource_type['id'])
        parse_docs resource_type, resource_type_elem, ns
        parse_params resource_type, resource_type_elem, ns
        parse_methods resource_type, resource_type_elem, ns
      end
      app_elem      
    end
    
    def parse_grammars(parent, parent_elem, ns)
      parent.xpath("wadl:grammars", ns).each do |grammars|
        grammars_elem = parent_elem.add_grammars
        parse_docs(grammars, grammars_elem, ns)
        parse_include(grammars, grammars_elem, ns)
      end
    end

    def parse_include(parent, parent_elem, ns)
      parent.xpath("wadl:include", ns).each do |include|
        include_elem = parent_elem.add_include(include['href'])
        parse_docs(include, include_elem, ns)
      end
    end

    def parse_docs(xml, obj, ns)
      xml.xpath('wadl:doc', ns).each do |docs|
        obj.add_doc(docs['title'], docs.content, docs['lang'])
      end      
    end

    def parse_params(parent, parent_elem, ns)
      parent.xpath('wadl:param', ns).each do |param|
        param_elem = parent_elem.add_param(param['name'], param['style'], param['href'], param['id'], param['type'], param['default'], param['path'], param['required'], param['repeating'], param['fixed'])
        parse_docs param, param_elem, ns
        param.xpath('wadl:option', ns).each do |option|
          option_elem = param_elem.add_option(option['value'], option['mediaType'])
          parse_docs option, option_elem, ns
        end
        param.xpath('wadl:link', ns).each do |link|
          link_elem = param_elem.add_link(link['resource_type'], link['rev'], link['rel'])
          parse_docs link, link_elem, ns
        end
      end
    end

    def parse_representation(parent, parent_elem, ns)
      parent.xpath('wadl:representation', ns).each do |repr|
        repr_elem = parent_elem.add_representation(repr['mediaType'], repr['element'], repr['href'], repr['id'], repr['profile'])
        parse_docs repr, repr_elem, ns
        parse_params repr, repr_elem, ns
      end
    end

    def parse_methods(parent, parent_elem, ns)
        parent.xpath('wadl:method', ns).each do |method|
          method_elem = parent_elem.add_method(method['name'], method['id'], method['href'])
          parse_docs method, method_elem, ns
          method.xpath('wadl:request', ns).each do |request|
            request_elem = method_elem.add_request
            parse_docs request, request_elem, ns
            parse_params request, request_elem, ns
            parse_representation request, request_elem, ns
          end
          method.xpath('wadl:response', ns).each do |response|
            response_elem = method_elem.add_response(response['status'])
            parse_docs response, response_elem, ns
            parse_params response, response_elem, ns
            parse_representation response, response_elem, ns
          end
        end
    end

  end

end