require 'simplecov'
require 'simplecov_small_badge'

SimpleCov.start 'rails' do
  add_filter do |source_file|
    source_file.lines.count < 5
  end

  add_filter "/app/model"
  # call SimpleCov::Formatter::BadgeFormatter after the normal HTMLFormatter
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCovSmallBadge::Formatter
  ])
end

SimpleCov.minimum_coverage 90

# configure any options you want for SimpleCov::Formatter::BadgeFormatter
SimpleCovSmallBadge.configure do |config|
  config.title_prefix = 'coverage'
  config.badge_width = 180
end

require 'minitest/autorun'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end

require './test/helpers/zabbix_api_helper'
