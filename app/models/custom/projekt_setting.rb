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
    if %w[main phase general sidebar footer debates proposals proposal_options polls budgets milestones].include? projekt_feature_prefix
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
        "projekt_feature.phase.event": '',
        "projekt_feature.phase.event_info": 'active',

        "projekt_feature.general.show_in_navigation": '',
        "projekt_feature.general.show_in_overview_page": '',
        "projekt_feature.general.hide_additional_info_in_projekt_selector": 'active',
        "projekt_feature.general.show_not_active_phases_in_projekts_page_sidebar": 'active',
        "projekt_feature.general.allow_downvoting_comments": 'active',

        "projekt_feature.sidebar.show_phases_in_projekt_page_sidebar": 'active',
        "projekt_feature.sidebar.show_map": 'active',
        "projekt_feature.sidebar.show_navigator_in_projekts_page_sidebar": 'active',
        "projekt_feature.sidebar.projekt_page_sharing": 'active',

        "projekt_feature.footer.show_projekt_footer": 'active',

        "projekt_feature.debates.show_report_button_in_sidebar": 'active',
        "projekt_feature.debates.show_related_content": 'active',
        "projekt_feature.debates.show_comments": 'active',
        "projekt_feature.debates.allow_attached_documents": '',
        "projekt_feature.debates.only_admins_create_debates": '',
        "projekt_feature.debates.allow_downvoting": 'active',
        "projekt_feature.debates.show_in_sidebar_filter": 'active',

        "projekt_feature.proposals.quorum_for_proposals": '',
        "projekt_feature.proposals.enable_proposal_support_withdrawal": 'active',
        "projekt_feature.proposals.enable_proposal_notifications_tab": '',
        "projekt_feature.proposals.enable_proposal_milestones_tab": '',
        "projekt_feature.proposals.show_report_button_in_proposal_sidebar": 'active',
        "projekt_feature.proposals.show_follow_button_in_proposal_sidebar": 'active',
        "projekt_feature.proposals.show_community_button_in_proposal_sidebar": 'active',
        "projekt_feature.proposals.show_related_content": 'active',
        "projekt_feature.proposals.show_comments": 'active',
        "projekt_feature.proposals.allow_attached_documents": 'active',
        "projekt_feature.proposals.only_admins_create_proposals": '',
        "projekt_feature.proposals.show_in_sidebar_filter": 'active',
        "projekt_feature.proposals.show_map": 'active',
        "projekt_feature.proposals.enable_summary": '',

        "projekt_feature.proposal_options.votes_for_proposal_success": 10000,

        "projekt_feature.polls.intermediate_poll_results_for_admins": 'active',
        "projekt_feature.polls.show_comments": 'active',
        "projekt_feature.polls.additional_information": 'active',
        "projekt_feature.polls.additional_info_for_each_answer": 'active',
        "projekt_feature.polls.show_in_sidebar_filter": 'active',

        "projekt_feature.budgets.remove_investments_supports": 'active',
        "projekt_feature.budgets.show_report_button_in_sidebar": 'active',
        "projekt_feature.budgets.show_follow_button_in_sidebar": 'active',
        "projekt_feature.budgets.show_community_button_in_sidebar": 'active',
        "projekt_feature.budgets.show_related_content": 'active',
        "projekt_feature.budgets.show_implementation_option_fields": 'active',
        "projekt_feature.budgets.show_user_cost_estimate": 'active',
        "projekt_feature.budgets.show_comments": 'active',
        "projekt_feature.budgets.enable_investment_milestones_tab": 'active',
        "projekt_feature.budgets.allow_attached_documents": 'active',
        "projekt_feature.budgets.only_admins_create_investment_proposals": '',
        "projekt_feature.budgets.show_map": 'active',
        "projekt_feature.budgets.show_results_after_first_vote": '',

        "projekt_feature.questions.show_questions_list": '',

        "projekt_feature.milestones.newest_first": '',

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
