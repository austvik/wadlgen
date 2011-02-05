require 'wadlgen'
require 'rails'

#
# Hooks the task up to Rails
#
module Wadlgen
  class Railtie < Rails::Railtie
    rake_tasks do
      require "rake/wadlgen"
    end
  end
end
