require 'test/unit'
require 'xml-object'

%w[ activesupport libxml ruby-debug leftright ].each do |library|
  begin; require library; rescue LoadError; nil; end
end

puts
puts "  XMLObject #{XMLObject::VERSION} (from #{XMLObject::LOCATION})"
puts

if defined? JRUBY_VERSION
  puts "  Using JRuby #{JRUBY_VERSION} (in #{RUBY_VERSION} mode)"
else
  puts "  Using Ruby #{RUBY_VERSION}"
end

unless defined? ActiveSupport
  puts "    ** Install 'activesupport' to test inflected plurals"
end

if defined?(LibXML) || defined?(JRUBY_VERSION)
  require 'xml-object/adapters/libxml'
  XMLObject.adapter = XMLObject::Adapters::REXML # set back to default
else
  puts "    ** Install 'libxml-ruby' to test the LibXML adapter"
end

puts

module XMLObject
  class TestCase < Test::Unit::TestCase
    # This makes descendants of this class use Test::Unit::TestCase#run, and
    # it makes this class not run at all in test suites.
    #
    # It also handle running each test suite under both XML adapters.
    #
    def run(*args, &block)
      return if self.class == XMLObject::TestCase

      XMLObject.adapter = XMLObject::Adapters::REXML
      super

      if defined? ::LibXML
        XMLObject.adapter = XMLObject::Adapters::LibXML
        super
      end
    end
  end
end