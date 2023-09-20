class ProjektPhaseSetting < ApplicationRecord
  SETTING_KINDS = %w[feature option].freeze
  SETTING_BANDS = %w[general form resource].freeze

  attr_accessor :form_field_disabled, :dependent_setting_ids, :dependent_setting_action

  belongs_to :projekt_phase, touch: true

  validates :projekt_phase_id, :key, presence: true
  validates :key, uniqueness: { scope: :projekt_phase_id }

  default_scope { order(id: :asc) }

  def kind_prefix
    key.split(".").first
  end

  def kind
    if SETTING_KINDS.include?(kind_prefix)
      kind_prefix
    else
      "feature"
    end
  end

  def band_prefix
    key.split(".").second
  end

  def band
    if SETTING_BANDS.include?(band_prefix)
      band_prefix
    else
      "configuration"
    end
  end

  class << self
    def defaults
      {
        "ProjektPhase::DebatePhase" => {
          "feature.general.only_admins_create_debates": "",

          "feature.form.allow_attached_image": "active",
          "feature.form.allow_attached_documents": "",

          "feature.resource.allow_voting": "active",
          "feature.resource.allow_downvoting": "active",
          "feature.resource.show_report_button_in_sidebar": "active",
          "feature.resource.show_related_content": "active",
          "feature.resource.show_comments": "active"

          # "feature.hide_projekt_selector": "active" #remove
        },

        "ProjektPhase::ProposalPhase" => {
          "feature.general.only_admins_create_proposals": "",

          "feature.form.allow_attached_image": "active",
           "feature.form.enable_summary": "",
          "feature.form.show_map": "active",
          "feature.form.enable_geoman_controls_in_maps": "active",
          "feature.form.allow_attached_documents": "",
          "feature.form.enable_external_video": "",

          "feature.resource.allow_voting": "active",
          "feature.resource.enable_proposal_support_withdrawal": "active",
          "feature.resource.quorum_for_proposals": "",
          "feature.resource.show_report_button_in_sidebar": "active",
          "feature.resource.show_follow_button_in_proposal_sidebar": "",
          "feature.resource.show_community_button_in_proposal_sidebar": "",
          "feature.resource.show_related_content": "",
          "feature.resource.enable_proposal_notifications_tab": "",
          "feature.resource.enable_proposal_milestones_tab": "",
          "feature.resource.show_comments": "active",
          "feature.resource.show_video_as_link": "",

          "option.resource.votes_for_proposal_success": 100

          # "feature.hide_projekt_selector": "active", delete
        },

        "ProjektPhase::VotingPhase" => {
          "feature.resource.intermediate_poll_results_for_admins": "active",
          "feature.resource.additional_information": "active",
          "feature.resource.additional_info_for_each_answer": "active",
          "feature.resource.show_comments": "active"
        },

        "ProjektPhase::BudgetPhase" => {
          "feature.general.only_admins_create_investment_proposals": "",
          "feature.general.show_results_after_first_vote": "",
          "feature.general.show_relative_ballotting_results": "",

          "feature.form.allow_attached_image": "active",
          "feature.form.show_implementation_option_fields": "",
          "feature.form.show_user_cost_estimate": "",
          "feature.form.show_map": "active",
          "feature.form.enable_geoman_controls_in_maps": "active",
          "feature.form.allow_attached_documents": "",

          "feature.resource.remove_investments_supports": "active",
          "feature.resource.show_report_button_in_sidebar": "active",
          "feature.resource.show_follow_button_in_sidebar": "",
          "feature.resource.show_community_button_in_sidebar": "",
          "feature.resource.show_related_content": "",
          "feature.resource.enable_investment_milestones_tab": "",
          "feature.resource.show_comments": "active"
        },

        "ProjektPhase::QuestionPhase" => {
          "feature.general.show_questions_list": ""
        },

        "ProjektPhase::LivestreamPhase" => {
          "feature.general.show_questions_list": ""
        },

        "ProjektPhase::MilestonePhase" => {
          "feature.general.newest_first": ""
        },

        "ProjektPhase::NewsfeedPhase" => {
          "option.general.newsfeed_id": "",
          "option.general.newsfeed_type": ""
        },

        "ProjektPhase::FormularPhase" => {
          "feature.general.only_registered_users": ""
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

  def enabled?
    value.present?
  end
end
