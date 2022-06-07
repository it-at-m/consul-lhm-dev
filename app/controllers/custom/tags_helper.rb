require_dependency Rails.root.join("app", "helpers", "tags_helper").to_s

module TagsHelper
  def taggables_path(taggable_type, tag_name)
    currently_selected_tags = params[:tags].present? ? params[:tags].split(',') : []
    currently_selected_tags.include?(tag_name) ? currently_selected_tags.delete(tag_name) : currently_selected_tags.push(tag_name)
    selected_tags = currently_selected_tags.join(',')

    updated_params = params.merge({tags: selected_tags}).permit(:tags, :geozone_affiliation, :geozone_restriction, :affiliated_geozones, :restricted_geozones, :sdg_goals, :sdg_targets, filter_projekt_ids: [])

    case taggable_type
    when "debate"
      debates_path(updated_params)
    when "proposal"
      proposals_path(updated_params)
    when "poll"
      polls_path(updated_params)
    when "budget/investment"
      budget_investments_path(@budget, updated_params)
    when "legislation/proposal"
      legislation_process_proposals_path(@process, updated_params)
    when "projekt"
      projekts_path(updated_params)
    else
      "#"
    end
  end

  def taggable_path(taggable)
    taggable_type = taggable.class.name.underscore
    case taggable_type
    when "debate"
      debate_path(taggable)
    when "proposal"
      proposal_path(taggable)
    when "poll"
      poll_path(taggable)
    when "budget/investment"
      budget_investment_path(taggable.budget_id, taggable)
    when "legislation/proposal"
      legislation_process_proposal_path(@process, taggable)
    else
      "#"
    end
  end
end
