require_dependency Rails.root.join("app", "components", "admin", "settings", "featured_settings_form_component").to_s

class Admin::Settings::FeaturedSettingsFormComponent < ApplicationComponent
  def initialize(feature, tab: nil, describedby: true, **extra_options)
    @feature = feature
    @tab = tab
    @describedby = describedby
    @extra_options = extra_options
  end

  private

    def options
      {
        data: { disable_with: text },
        "aria-labelledby": dom_id(feature, :title),
        "aria-describedby": (dom_id(feature, :description) if describedby?),
        "aria-pressed": enabled?
      }.merge(@extra_options)
    end
end
