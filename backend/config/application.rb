require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    config.frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:3000")
    config.backend_url = ENV.fetch("BACKEND_URL", "http://localhost:4000")
    config.open_ai_api_key = ENV.fetch("OPEN_AI_API_KEY", "")
    config.active_job.queue_adapter = :sidekiq

    Rails.application.routes.default_url_options[:host] = config.backend_url

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: true,
                       request_specs: true
    end
    config.api_only = true
    config.session_store :cookie_store, key: "_your_app_session"
    config.middleware.use ActionDispatch::Cookies

    config.middleware.use config.session_store, config.session_options
  end
end
