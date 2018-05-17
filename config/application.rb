require_relative 'boot'

# require 'rails/all'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_cable/engine'
require 'active_model/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ZabbixScreensGenerator
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.cache_store = :memory_store
  end
end
