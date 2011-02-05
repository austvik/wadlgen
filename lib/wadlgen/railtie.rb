require 'wadlgen'
require 'rails'

module Wadlgen
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'lib/rake/wadlgen.task'
    end
  end
end
