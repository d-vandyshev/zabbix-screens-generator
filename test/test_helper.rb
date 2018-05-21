require 'simplecov'
require 'simplecov-formatter-badge'
SimpleCov.start 'rails' do
  add_filter do |source_file|
    source_file.lines.count < 5
  end
end
SimpleCov.formatter =
    SimpleCov::Formatter::MultiFormatter.new \
    [SimpleCov::Formatter::HTMLFormatter,
     SimpleCov::Formatter::BadgeFormatter]

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
