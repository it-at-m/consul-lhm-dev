class UserResources::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  delegate :suggest_data, to: :helpers
  delegate :current_user, to: :helpers

  attr_reader :resource

  def initialize(resource, url:, title:, selected_projekt:, categories:)
    @resource = resource
    @title = title
    @url = url
    @selected_projekt = selected_projekt
    @categories = categories
  end

  def projekt_phase
    @projekt_phase ||=
      if params[:projekt_phase_id] && @resource.new_record?
        Projekt.find(params[:projekt_id]).projekt_phases.find(params[:projekt_phase_id])
      elsif @resource.persisted?
        @resource.projekt_phase
      end
  end

  def selected_projekt_id
    @selected_projekt_id ||=
      if params[:projekt_id] && @resource.new_record?
        params[:projekt_id]
      elsif @resource.persisted?
        @resource.projekt_phase&.projekt_id
      end
  end

  def selected_projekt_phase_id
    @selected_projekt_phase_id ||= projekt_phase&.id
  end

  def back_link
    case @resource
    when Debate
      debates_back_link_path
    when Proposal
      proposals_back_link_path
    end
  end

  def i18n_scope
    case @resource
    when Debate
      "debates"
    when Proposal
      "proposals"
    end
  end

  def debates_back_link_path
    helpers.resources_back_link(fallback_path: debates_path)
  end

  def proposals_back_link_path
    helpers.resources_back_link(fallback_path: proposals_path)
  end

  def title_max_length
    case resource
    when Debate
      Debate.title_max_length
    else
      Proposal.title_max_length
    end
  end

  def max_description_lenght
    case resource
    when Debate
      Debate.description_max_length
    else
      2000
    end
  end

  def banner_class_name
    "-#{resource.class.name.downcase}"
  end

  def base_class_name
    class_name = ""

    if phase_feature_enabled?("form.allow_attached_image") || !feature?(:allow_images)
      class_name += " -no-image"
    end

    class_name
  end

  def phase_feature_enabled?(feature_name)
    (projekt_phase.present? && helpers.projekt_phase_feature?(projekt_phase, feature_name))
  end

  def render_map?
    resource.is_a?(Proposal)
  end

  def projekt_selector_class
    if (params[:origin] == "projekt" && params[:projekt_id].present?) || resource.persisted?
      "hide"
    else
      ""
    end
  end
end
