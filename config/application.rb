require_relative 'boot'

require 'rails/all'

require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mossu
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # Taken from: https://github.com/nsarno/knock/issues/245#issuecomment-524918268
    config.load_defaults 6.0 and config.autoloader = :classic

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.active_job.queue_adapter = :sidekiq
    config.webpacker.check_yarn_integrity = false

    config.middleware.use Rack::Deflater
    config.middleware.use Prometheus::Middleware::Exporter
    config.middleware.use Prometheus::Middleware::Collector
  end
end
