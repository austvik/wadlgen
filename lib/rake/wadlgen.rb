#
# Task to generate WADL from Rails routes
#

desc "Generates WADL descriptors from routes"
task :wadlgen => :environment do
  require 'wadlgen'
  Wadlgen::Wadl.generate("http://example.com/")
end
