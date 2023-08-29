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

  def render_map?
    resource.is_a?(Proposal)
  end

  def projekt_selector_class
    (params[:origin] == 'projekt' && params[:projekt_id].present?) ? "hide" : ""
  end
end
