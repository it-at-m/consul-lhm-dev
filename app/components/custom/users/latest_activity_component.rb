class Users::LatestActivityComponent < ApplicationComponent
  delegate :current_user, to: :helpers

  def initialize
  end

  def render?
    current_user.present? && valid_filters.any?
  end

  def current_filter
    if valid_filters.include?(params[:filter])
      params[:filter]
    else
      valid_filters.first
    end
  end

  def valid_filters
    @valid_filters ||= [
      ("proposals" if feature?(:proposals)),
      ("debates" if feature?(:debates)),
      ("budget_investments" if feature?(:budgets)),
      "comments",
      "follows"
    ].compact.select { |filter| send(filter).any? }
  end

  private

    def resources
      list =
        case current_filter
        when "debates"
          debates
        when "proposals"
          proposals
        when "budget_investments"
          budget_investments
        when "comments"
          comments
        end

      if current_filter == "follows"
        return follows.map(&:followable)
      end

      list.order(created_at: :desc).limit(3)
    end

    def comments?
      current_filter == "comments"
    end

    def proposals
      @proposals ||= Proposal.where(author_id: current_user.id)
    end

    def debates
      @debates ||= Debate.where(author_id: current_user.id)
    end

    def comments
      @comments ||=
        Comment.not_valuations
               .not_as_admin_or_moderator
               .where(user_id: current_user.id)
               .where.not(commentable_type: disabled_commentables)
               .includes(:commentable)
    end

    def budget_investments
      @budget_investments ||= Budget::Investment.where(author_id: current_user.id)
    end

    def follows
      @follows ||= current_user.follows.select { |follow| follow.followable.present? }.first(3)
    end

    def disabled_commentables
      [
        ("Debate" unless feature?(:debates)),
        ("Budget::Investment" unless feature?(:budgets)),
        (["Legislation::Question",
          "Legislation::Proposal",
          "Legislation::Annotation"] unless feature?(:legislation)),
        (["Poll", "Poll::Question"] unless feature?(:polls)),
        ("Proposal" unless feature?(:proposals))
      ].flatten.compact
    end

    def list_params
      params = {
        title: t("custom.welcome.latest_activity.title"),
        current_filter: current_filter,
        filters: valid_filters,
        remote_url: "latest_activity",
        filter_param: "filter",
        filter_i18n_namespace: "custom.welcome.latest_activity"
      }

      if current_filter == "comments"
        params[:hide_view_mode_button] = true
      else
        params[:resources] = resources
      end

      params
    end
end
