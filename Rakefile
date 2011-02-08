require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('wadlgen', '0.1.0') do |p|
  p.description = 'Generate WADL from rails routes'
  p.url = 'https://github.com/austvik/wadlgen'
  p.author = 'Jorgen Austvik'
  p.email = 'jaustvik@acm.org'
  p.ignore_pattern = ['tmp/*', 'nbproject/**/*']
  p.runtime_dependencies = ['builder', 'nokogiri']
  p.development_dependencies = ['test-unit']
  p.require_paths = ['lib']
  p.retain_gemspec = true
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each {|ext| load ext}
