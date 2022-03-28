class ProjektSetting < ApplicationRecord
  belongs_to :projekt

  validates :key, presence: true, uniqueness: { scope: :projekt_id }

  default_scope { order(id: :asc) }

  after_update :sync_related_projekt_children_active_setting, if: Proc.new { |setting| setting.key == "projekt_feature.main.activate" }

  def prefix
    key.split(".").first
  end

  def type
    if %w[projekt_feature projekt_newsfeed].include? prefix
      prefix
    else
      "configuration"
    end
  end

  def projekt_feature_prefix
    key.split(".").second
  end

  def projekt_feature_type
    if %w[main phase general sidebar footer].include? projekt_feature_prefix
      projekt_feature_prefix
    else
      "configuration"
    end
  end

  class << self

    def defaults
      {
        "projekt_feature.main.activate": '',

        "projekt_feature.phase.comment": '',
        "projekt_feature.phase.comment_info": 'active',
        "projekt_feature.phase.debate": '',
        "projekt_feature.phase.debate_info": 'active',
        "projekt_feature.phase.proposal": '',
        "projekt_feature.phase.proposal_info": 'active',
        "projekt_feature.phase.voting": '',
        "projekt_feature.phase.voting_info": 'active',
        "projekt_feature.phase.budget": '',
        "projekt_feature.phase.budget_info": 'active',
        "projekt_feature.phase.milestone": '',
        "projekt_feature.phase.milestone_info": 'active',
        "projekt_feature.phase.projekt_notification": '',
        "projekt_feature.phase.projekt_notification_info": 'active',
        "projekt_feature.phase.newsfeed": '',
        "projekt_feature.phase.newsfeed_info": 'active',

        "projekt_feature.general.show_in_navigation": '',
        "projekt_feature.general.show_in_overview_page": '',
        "projekt_feature.general.hide_additional_info_in_projekt_selector": '',
        "projekt_feature.general.show_not_active_phases_in_projekts_page_sidebar": '',
        "projekt_feature.general.show_map": 'active',
        "projekt_feature.general.only_admins_create_debates_proposals": '',

        "projekt_feature.sidebar.projekt_page_sharing": 'active',
        "projekt_feature.sidebar.show_phases_in_projekt_page_sidebar": 'active',
        "projekt_feature.sidebar.show_navigator_in_projekts_page_sidebar": true,

        "projekt_feature.footer.show_projekt_footer": 'active',

        "projekt_newsfeed.id": '',
        "projekt_newsfeed.type": '',

        "projekt_custom_feature.default_footer_tab": nil
      }
    end

    def ensure_existence
      Projekt.all.each do |projekt|

        defaults.each do |name, value|
          unless find_by(key: name, projekt_id: projekt.id)
            self.create(key: name, value: value, projekt_id: projekt.id)
          end
        end

      end
    end

    def destroy_obsolete
      ProjektSetting.all.each{ |setting| setting.destroy unless defaults.keys.include?(setting.key.to_sym) }
    end

  end

  def enabled?
    value.present?
  end

  def short_name
    I18n.t("custom.settings.#{self.key}")
  end

  def sync_related_projekt_children_active_setting
    projekt.all_children_projekts.map do |child_projekt|
      child_projekt.projekt_settings.find_by( key: 'projekt_feature.main.activate' ).
        update(value: self.value)
    end
  end

end
