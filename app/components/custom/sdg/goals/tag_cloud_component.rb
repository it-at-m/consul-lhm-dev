require_dependency Rails.root.join("app", "components", "sdg", "goals", "tag_cloud_component").to_s

class SDG::Goals::TagCloudComponent < ApplicationComponent
  def initialize(class_name, sdg_targets: [])
    @class_name = class_name
    @sdg_targets = sdg_targets
  end

  private

  def selected_goals
    return [] unless params[:sdg_goals].present?
    params[:sdg_goals].split(',')
  end

  def target_options
    if params[:sdg_goals]
      selected_target =
        if params[:sdg_targets].present?
          params[:sdg_targets].split(',').first
        end

      options_from_collection_for_select(@sdg_targets, :code, :code, selected_target)
    end
  end
end
