module Wadlgen

  class Merge

    attr_accessor :initial_app, :additional_app

    def initialize(initial, addition)
      self.initial_app = initial
      self.additional_app = addition
    end

    def merge
      merge_application self.initial_app, self.additional_app
    end

  private

    def merge_application(initial, addition)
      result = Wadlgen::Application.new
      merge_docs result, initial.docs, addition.docs
      merge_grammars result, initial.grammars, addition.grammars
      merge_resources_elem result, initial.resources, addition.resources
      merge_resource_types result, initial.resource_types, addition.resource_types
      result
    end

    def merge_resources_elem(target, initial, additional)
      initial.each do |resources|
        res = target.add_resources(resources.base)
        merge_docs res, resources.docs
        if additional.has_resources? resources.base
          merge_resources res, resources.resources, additional.get_resources(resources.base)
        else
          merge_resources res, resources.resources
        end
      end
      additional.each do |resources|
        unless target.has_resources? resources.base
          res = target.add_resources(resources.base)
          merge_docs res, resources.docs
        end
      end
    end

    def merge_resource_types(target, initial, additional)
      if initial and initial.length > 0
        initial.resource_types.each do |initial_res_type|
          res_type = target.add_resource_type(initial_res_type.id)
          merge_docs res_type, initial_res_type.docs
          if additional.has_resource_type? initial_res_type.id
            other = additional.get_resource_type initial_res_type.id
          else
            other = []
          end
          merge_params res_type, initial_res_type.params, other.params
          merge_methods res_type, initial_res_type.methods, other.methods
          merge_resources res_type, initial_res_type.resources, other.resources
        end
      end
      if additional and additional.length > 0
        additional.resource_types.each do |additional_res_type|
          unless target.has_resource_type? additional_res_type.id
            res_type = target.add_resource_type(additional_res_type.id)
            merge_docs res_type, additional_res_type.docs
            merge_params res_type, additional_res_type.params
            merge_methods res_type, additional_res_type.methods
            merge_resources res_type, additional_res_type.resources
          end
        end
      end
    end

    def merge_resources(target, initial, additional = [])
      (initial + additional).each do |init_res|
        if target.has_resource? init_res.path
            res = get_resource init_res.type, init_res.path
            merge_docs res, res.docs, add_res.docs
            merge_params res, res.params, add_res.params
            merge_methods res, res.methods, add_res.methods
            merge_resources res, res.resources, add_res.resources
        else
          res = target.add_resource init_res.type, init_res.id, init_res.query_type
          merge_docs res, init_res.docs
          merge_params res, init_res.params
          merge_methods res, init_res.methods
          merge_resources res, init_res.resources
        end
      end
    end

    def merge_methods(target, initial, additional = [])
      (initial + additional).each do |init_meth|
        if target.has_method? init_meth.name, init_meth.id
          meth = target.get_method init_meth.name, init_meth.id
          merge_docs meth, meth.docs, init_meth.docs
          merge_request meth, meth.docs, init_meth.request
          merge_responses meth, meth.docs, init_meth.responses
        else
          meth = target.add_method init_meth.name, init_meth.id, init_meth.href
          merge_docs meth, init_meth.docs
          merge_request meth, init_meth.request
          merge_responses meth, init_meth.responses
        end
      end
    end

    def merge_request(target, initial, additional = nil)
      if target.request.nil?
        req = target.add_request
        merge_docs req, initial.docs
        merge_params req, initial.params
        merge_representations req, initial.representation
      else
        req = target.request
        merge_docs req, initial.docs
        merge_params req, initial.params
        merge_representations req, initial.representation
      end

      if additional
        req = target.request
        merge_docs req, req.docs, additional.docs
        merge_params req, req.params, additional.params
        merge_representations req, req.representation, additional.representation
      end

    end

    def merge_responses(target, initial, additional = [])
      (initial + additional).each do |add_resp|
        if target.has_response? add_resp.status
          resp = target.get_response add_resp.status
          merge_docs resp, resp.docs, add_resp.docs
          merge_params resp, resp.params, add_resp.params
          merge_representations resp, resp.representations, add_resp.representations
        else
          resp = target.add_response add_resp.status
          merge_docs resp, add_resp.docs
          merge_params resp, add_resp.params
          merge_representations resp, add_resp.representations
        end
      end
    end

    def merge_representations(target, initial, additional = [])
      (initial + additional).each do |add_repr|
        if target.has_representation? add_repr.media_type
          repr = target.get_representation add_repr.media_type
          merge_docs repr, repr.docs, add_repr.docs
          merge_params repr, repr.params, add_repr.params
        else
          repr = target.add_representation add_repr.media_type
          merge_docs repr, add_repr.docs
          merge_params repr, add_repr.params
        end
      end
    end

    def merge_params(target, initial, additional = [])
      (initial + additional).each do |add_param|
        if target.has_param? add_param.name, add_param.style
          param = target.get_param add_param.name, add_param.style
          merge_docs param, param.docs, add_param.docs
          merge_options param, param.options, add_param.options
          merge_link param, param.link, add_param.link
        else
          param = target.add_param add_param.value,     add_param.style,
                                   add_param.href,      add_param.id,
                                   add_param.type,      add_param.default,
                                   add_param.path,      add_param.required,
                                   add_param.repeating, add_param.fixed
          merge_docs param, add_param.docs
          merge_options param, add_param.options
          merge_link param, add_param.link
        end
      end
    end

    def merge_options(target, initial, additional = [])
      (initial + additional).each do |add_opt|
        if target.has_option? add_opt.value
          opt = target.get_option add_opt.value
          merge_docs opt, opt.docs, add_opt.docs
        else
          opt = target.add_option add_opt.value, add_opt.media_type
          merge_docs opt, add_opt.docs
        end
      end
    end

    def merge_link(target, initial, additional = [])
      # Only one link - so no merging, keep the initial
      if initial
        link = target.add_link(initial.resource_type, initial.rev, initial.rel)
        merge_docs link, initial.docs
      end
    end

    def merge_grammars(target, initial, additional)
      grammars = target.add_grammars
      merge_docs grammars, initial.docs, additional.docs
      merge_includes grammars, initial.includes, additional.includes
    end

    def merge_includes(target, initial, additional)
      initial.each do |incl|
        incl = target.add_include incl.href
        merge_docs incl, incl.docs
      end
      additional.each do |incl|
        unless target.has_include?(incl.href)
          incl = target.add_include incl.href
          merge_docs incl, incl.docs
        end
      end
    end

    def merge_docs(target, initial, additional = [])
      if initial and initial.length > 0
        initial.each do |doc|
          unless target.has_doc? doc.title
            target.add_doc doc.title, doc.text, doc.xml_lang
          end
        end
      else
        if additional and additional.length > 0
          additional.each do |doc|
            unless target.has_doc? doc.title
              target.add_doc doc.title, doc.text, doc.xml_lang
            end
          end
        end
      end
    end

  end

end