class Shared::CommentsFormComponent < ApplicationComponent
  attr_reader :record
  delegate :user_signed_in?, :link_to_signin, :link_to_signup,
           :link_to_verify_account, :current_user, :can?, to: :helpers

  def initialize(record)
    @record = record
  end

  private

    def projekt_phase
      return record.comment_phase if record.is_a?(Projekt)
      return record.projekt_phase if record.respond_to?(:projekt_phase)

      nil
    end

    def permission_problem_key
      @permission_problem_key ||= projekt_phase.permission_problem(current_user)
    end

    def cannot_vote_text
      return nil if permission_problem_key.blank?

      if permission_problem_key == :not_logged_in
        sanitize(t(path_to_key,
                 sign_in: link_to_signin, sign_up: link_to_signup))

      else
        sanitize(t(path_to_key,
                 verify: link_to_verify_account,
                 city: Setting["org_name"],
                 geozones: projekt_phase.geozone_restrictions_formatted,
                 age_restriction: projekt_phase.age_restriction_formatted,
                 restricted_streets: projekt_phase.street_restrictions_formatted,
                 individual_group_values: projekt_phase.individual_group_value_restriction_formatted
        ))

      end
    end

    def path_to_key
      if record.respond_to?(:projekt_phase) &&
        I18n.exists?("custom.projekt_phases.permission_problem.commenting.#{record.projekt_phase.name}.#{permission_problem_key}")
        "custom.projekt_phases.permission_problem.commenting.#{record.projekt_phase.name}.#{permission_problem_key}"
      else
        "custom.projekt_phases.permission_problem.commenting.shared.#{permission_problem_key}"
      end
    end
end
