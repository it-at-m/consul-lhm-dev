module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :de
    config.i18n.available_locales = [:en, :de]
  end
end
