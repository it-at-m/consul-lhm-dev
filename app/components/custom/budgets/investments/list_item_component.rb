# frozen_string_literal: true

class Budgets::Investments::ListItemComponent < ApplicationComponent
  attr_reader :budget_investment

  def initialize(budget_investment:, ballot:, top_level_active_projekts:, top_level_archived_projekts:, wide: false)
    @budget_investment = budget_investment
    @wide = wide
    @ballot = ballot
    @top_level_active_projekts = top_level_active_projekts
    @top_level_archived_projekts = top_level_archived_projekts
  end

  def component_attributes
    {
      resource: @budget_investment,
      projekt: @budget_investment.budget.projekt,
      title: budget_investment.title,
      description: budget_investment.description,
      wide: @wide,
      url: helpers.url_for(budget_investment),
      image_url: budget_investment.image&.variant(:medium),
      date: budget_investment.created_at,
      author: budget_investment.author,
      image_placeholder_icon_class: "fa-euro-sign",
      id: budget_investment.id
    }
  end

  def budget_investment_url
    helpers.budget_investment_path(budget_investment.id)
  rescue
    ""
  end

  def show_status_message?
    (
      budget_investment.budget.accepting? ||
      budget_investment.budget.reviewing? ||
      budget_investment.budget.valuating? ||
      budget_investment.budget.publishing_prices? ||
      budget_investment.budget.reviewing_ballots? ||
      budget_investment.budget.finished?
    )
  end

  def status_message_class
    if budget_investment.budget.accepting?
      "success"
    else
      "warning"
    end
  end
end
