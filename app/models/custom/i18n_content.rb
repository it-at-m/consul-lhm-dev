require_dependency Rails.root.join("app", "models", "i18n_content").to_s

class I18nContent < ApplicationRecord
  def self.all_translation_strings
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?

    all_groups = I18n.backend.send(:translations)[I18n.locale].select do |key, _translations|
      key.in?([:debates, :community, :proposals, :polls, :layouts, :mailers, :management, :welcome, :machine_learning, :custom, :cli, :devise_views])
    end

    flat_hash(all_groups).keys.map do |string|
      I18nContent.find_or_initialize_by(key: string)
    end
  end
end
