require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ThankYou
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    csp = [
      "default-src 'self'",
      "script-src 'self' https://www.google-analytics.com/ https://www.gstatic.com/ https://cdn.ravenjs.com/",
      "connect-src 'self' https://fcm.googleapis.com/",
      "img-src https:",
      "font-src https:",
      "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com/",
      "report-uri https://abraham.report-uri.io/r/default/csp/reportOnly"
    ]

    if Rails.env.production?
      config.action_dispatch.default_headers.merge!({
        'Content-Security-Policy-Report-Only' => csp.join('; ')
      })
    end

    config.generators do |g|
      g.javascript_engine :js
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :test_unit, fixture: false
    end

    Raven.configure do |config|
      config.dsn = 'https://5e69813822924122ae73456b7057c338:aa26ed7c63124ce6a297dc2ff28d869f@sentry.io/135599'
      config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
      config.environments = ['production']
    end
  end
end
