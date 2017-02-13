require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ThankYou
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.generators do |g|
      g.javascript_engine :js
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :test_unit, fixture: false
    end

    Raven.configure do |config|
      config.dsn = 'https://5e69813822924122ae73456b7057c338:aa26ed7c63124ce6a297dc2ff28d869f@sentry.io/135599'
      config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
      # config.environments = [:production]
    end
  end
end
