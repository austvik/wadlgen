#
# Task to generate WADL from Rails routes
#

desc "Generates WADL descriptors from routes"
task :wadlgen => :environment do
  require 'wadlgen'
  puts Wadlgen::Wadl.generate Rails.application, "http://example.com/"
end
