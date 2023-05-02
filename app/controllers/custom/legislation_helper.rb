module LegislationHelper
  def cannot_annotate_callout_text(permission_problem_key, legislation_phase)
    return nil if permission_problem_key.blank?

    if permission_problem_key == :not_logged_in
      sanitize(t("custom.projekt_phases.permission_problem.legislation_annotations.#{permission_problem_key}",
               sign_in: link_to_signin, sign_up: link_to_signup))

    else
      sanitize(t("custom.projekt_phases.permission_problem.legislation_annotations.#{permission_problem_key}",
               verify: link_to_verify_account,
               city: Setting["org_name"],
               geozones: legislation_phase.geozone_restrictions_formatted,
               age_restriction: legislation_phase.age_restriction_formatted,
               restricted_streets: legislation_phase.street_restrictions_formatted,
               individual_group_values: legislation_phase.individual_group_value_restriction_formatted
              ))
    end
  end
end
