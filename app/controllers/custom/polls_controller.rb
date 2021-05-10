require_dependency Rails.root.join("app", "controllers", "polls_controller").to_s

class PollsController < ApplicationController

  include CommentableActions

  before_action :load_categories, only: [:index]

  helper_method :resource_model, :resource_name

  def index
    @tag_cloud = tag_cloud

    @polls = @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones)
    take_only_by_tag_names
    take_by_projekts

    @all_polls = @polls

    @polls = Kaminari.paginate_array(
      @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones).sort_for_list
    ).page(params[:page])
  end

  private

    def section(resource_name)
      "polls"
    end

    def resource_model
      Poll
    end

  def take_only_by_tag_names
    if params[:tags].present?
      @polls = @polls.tagged_with(params[:tags].split(","), all: true, any: :true)
    end
  end

  def take_by_projekts
    if params[:projekts].present?
      @polls = @polls.where(projekt_id: params[:projekts].split(',') ).distinct
    end
  end
end
