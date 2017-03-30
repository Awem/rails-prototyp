Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Devise mailer
  config.action_mailer.default_url_options = { host: 'localhost', port: 4200, protocol: 'http' }
  # config.action_mailer.default_url_options = { host: 'rproto-webserver.herokuapp.com', protocol: 'https' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'hx.server.net',
                                         port: 587,
                                         authentication: 'plain',
                                         enable_starttls_auto: true,
                                         openssl_verify_mode: 'none',
                                         user_name: ENV['DEV_MAILER_USER'],
                                         password: ENV['DEV_MAILER_PASSWORD'] }

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # disable quiet_assets
  config.quiet_assets = false

  # enable bullet
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
  end
end
