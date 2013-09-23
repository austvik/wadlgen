wadlgen
=======

An experiment to try to generate WADL
(http://www.w3.org/Submission/wadl/) based on the routing information
found in Rails 3 config/routes.rb.

Approach:
- Minimal rake task that calls a library to generate the WADL
- Save application.wadl in public/
- Let the user edit application.wadl to add information that can't be 
  extracted, and preserve what the user has added the next time the
  task is run
- Needs Ruby 1.9.2 for ordered hashes in tests, also works on 1.8.7.

What works:
- Parse a WADL file to an object model
- Generate a WADL file from an object model
- Parse a Rails Route file to a object model
- Rake task to parse the rails route
- merge two object models
- make the rails task write a public/application.wadl file
- 100% code coverage by unit tests

Rails 3 Usage:

  Add this to the Gemfile:
  gem 'wadlgen', :git => 'git://github.com/austvik/wadlgen.git'

  To generate a public/application.wadl:
  rake wadlgen

  Now you can edit public/application.wadl. The next time you run
  rake wadlgen, any changes to the application will be merged into your
  WADL file, while your changes are preserved.

Programmatic usage:

  There are several methods that can be used to generate, merge and write
  wadl object structures:

  require 'wadlgen'

  # Generate a WADL XML document based on a Rails application
  # and base.
  Wadlgen::Wadl.generate(application, base)

  # parses a given XML string, and generates a Wadlgen::Application
  # object from it.
  Wadlgen::Wadl.parse_xml(xml_doc)

  # Parses routes from Rails 3, and generates a Wadlgen::Application
  # object from it.
  Wadlgen::Wadl.parse_route(application, base)

  # Generates a WADL XML string based on a Wadlgen::Application object
  Wadlgen::Wadl.generate_wadl(application)

  # Merges two Wadlgen::Application objects and returns the result
  # as another Wadlgen::Application object.
  Wadlgen::Wadl.merge(initial_application, additional_application)

  In addition the Wadlgen::* classes in src/wadlgen/classes.rb can be used
  to understand the object model created from these methods, or to generate
  structures to write to a WADL XML file.

