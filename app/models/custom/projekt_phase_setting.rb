class ProjektPhaseSetting < ApplicationRecord
  attr_accessor :form_field_disabled, :dependent_setting_ids, :dependent_setting_action

  belongs_to :projekt_phase, touch: true

  validates :projekt_phase_id, :key, presence: true
  validates :key, uniqueness: { scope: :projekt_phase_id }

  default_scope { order(id: :asc) }

  class << self
    def defaults
      {
        "ProjektPhase::DebatePhase" => {
          "feature.show_report_button_in_sidebar": "active",
          "feature.show_related_content": "active",
          "feature.show_comments": "active",
          "feature.allow_attached_image": "active",
          "feature.allow_attached_documents": "",
          "feature.only_admins_create_debates": "",
          "feature.allow_downvoting": "active",
          "feature.show_in_sidebar_filter": "active",
          "feature.allow_voting": "active",
          "feature.hide_projekt_selector": "active"
        },

        "ProjektPhase::ProposalPhase" => {
          "feature.quorum_for_proposals": "",
          "feature.enable_proposal_support_withdrawal": "active",
          "feature.enable_proposal_notifications_tab": "",
          "feature.enable_proposal_milestones_tab": "",
          "feature.show_report_button_in_proposal_sidebar": "active",
          "feature.show_follow_button_in_proposal_sidebar": "active",
          "feature.show_community_button_in_proposal_sidebar": "active",
          "feature.show_related_content": "active",
          "feature.show_comments": "active",
          "feature.allow_attached_image": "active",
          "feature.allow_attached_documents": "active",
          "feature.only_admins_create_proposals": "",
          "feature.show_in_sidebar_filter": "active",
          "feature.show_map": "active",
          "feature.enable_summary": "",
          "feature.allow_voting": "active",
          "feature.enable_external_video": "active",
          "feature.enable_geoman_controls_in_maps": "active",
          "feature.hide_projekt_selector": "active",
          "option.votes_for_proposal_success": 10000
        },

        "ProjektPhase::VotingPhase" => {
          "feature.intermediate_poll_results_for_admins": "active",
          "feature.show_comments": "active",
          "feature.additional_information": "active",
          "feature.additional_info_for_each_answer": "active",
          "feature.show_in_sidebar_filter": "active"
        },

        "ProjektPhase::BudgetPhase" => {
          "feature.remove_investments_supports": "active",
          "feature.show_report_button_in_sidebar": "active",
          "feature.show_follow_button_in_sidebar": "active",
          "feature.show_community_button_in_sidebar": "active",
          "feature.show_related_content": "active",
          "feature.show_implementation_option_fields": "active",
          "feature.show_user_cost_estimate": "active",
          "feature.show_comments": "active",
          "feature.enable_investment_milestones_tab": "active",
          "feature.allow_attached_documents": "active",
          "feature.only_admins_create_investment_proposals": "",
          "feature.show_map": "active",
          "feature.show_results_after_first_vote": "",
          "feature.enable_geoman_controls_in_maps": "active",
          "feature.show_relative_ballotting_results": ""
        },

        "ProjektPhase::QuestionPhase" => {
          "feature.show_questions_list": ""
        },

        "ProjektPhase::MilestonePhase" => {
          "feature.newest_first": ""
        },

        "ProjektPhase::NewsfeedPhase" => {
          "option.newsfeed_id": "",
          "option.newsfeed_type": ""
        }
      }
    end

    def add_new_settings
      defaults.each do |phase_class, phase_settings|
        phase_class.to_s.constantize.all.find_each do |phase|
          phase_settings.each do |key, value|
            phase.settings.create!(key: key, value: value) unless phase.settings.find_by(key: key)
          end
        end
      end
    end

    def destroy_obsolete
      defaults.each do |phase_class, phase_settings|
        phase_class.to_s.constantize.all.find_each do |phase|
          phase.settings.each do |setting|
            setting.destroy! unless phase_settings.keys.include?(setting.key.to_sym)
          end
        end
      end
    end
  end

  def kind
    key.split(".").first
  end

  def enabled?
    value.present?
  end
end
