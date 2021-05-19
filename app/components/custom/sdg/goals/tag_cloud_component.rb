require_dependency Rails.root.join("app", "components", "sdg", "goals", "tag_cloud_component").to_s

class SDG::Goals::TagCloudComponent < ApplicationComponent

  private

  def selected_goals
    return [] unless params[:sdg_goals].present?
    params[:sdg_goals].split(',')
  end

  def selected_target
    return nil unless params[:sdg_targets].present?
    params[:sdg_targets].split(',').first
  end

  def target_options
    if params[:sdg_goals]
      selected_goals = params[:sdg_goals].split(',').map{ |sdg| sdg.to_i }
      options_from_collection_for_select(SDG::Target.includes(:goal).where(sdg_goals: { code: selected_goals } ).order(:code), :code, :code, selected_target)
    end
  end
end
