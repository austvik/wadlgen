#
# Task to generate WADL from Rails routes
#

desc "Generates WADL descriptors from routes"
task :wadlgen => :environment do
  require 'wadlgen'

  file_name = 'public/application.wadl'
  base = "http://example.com/"
  if File.exist?(file_name)
    original_file = File.open(file_name, "rb").read
    original = Wadlgen::Wadl.parse_xml original_file
    routes = Wadlgen::Wadl.parse_route Rails.application, base
    merge = Wadlgen::Wadl.merge original, routes
    wadl = Wadlgen::Wadl.generate_wadl merge
    File.open(file_name, 'w') {|f| f.write(wadl) }
  else
    wadl = Wadlgen::Wadl.generate Rails.application, base
    File.open(file_name, 'w') {|f| f.write(wadl) }
  end
  puts "Wrote WADL to '#{file_name}', please edit to add details."
end
