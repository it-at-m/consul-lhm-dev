class Users::NewPublicActivityComponent < ApplicationComponent
  attr_reader :user
  delegate :current_user, :current_path_with_query_params, to: :helpers

  def initialize(user)
    @user = user
  end

  def valid_access?
    user.public_activity || authorized_current_user?
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
      ("follows" if valid_interests_access?(user))
    ].compact.select { |filter| send(filter).any? }
  end

  private

    def valid_interests_access?(user)
      user.public_interests || user == current_user
    end

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

      list.order(created_at: :desc).page(params[:page])
    end

    def comments?
      current_filter == "comments"
    end

    def authorized_current_user?
      current_user == user || current_user&.moderator? || current_user&.administrator?
    end

    def proposals
      if authorized_current_user?
        @proposals ||= Proposal.where(author_id: user.id)
      else
        @proposals ||= Proposal.base_selection.where(author_id: user.id)
      end
    end

    def debates
      @debates ||= Debate.where(author_id: user.id)
    end

    def comments
      @comments ||=
        Comment.not_valuations
               .not_as_admin_or_moderator
               .where(user_id: user.id)
               .where.not(commentable_type: disabled_commentables)
               .includes(:commentable)
    end

    def budget_investments
      @budget_investments ||= Budget::Investment.where(author_id: user.id)
    end

    def follows
      @follows ||= user.follows.select { |follow| follow.followable.present? }
    end

    def count(filter)
      send(filter).count
    end

    def render_user_partial(filter)
      render "users/#{filter}", "#{filter}": send(filter).order(created_at: :desc).page(page)
    end

    def page
      params[:page]
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
        title: current_user == user ? t("custom.users.my_activity") : t("custom.users.activity"),
        current_filter: current_filter,
        filters: valid_filters,
        filter_param: "filter",
        filter_i18n_namespace: "custom.user_page",
        remote_url: remote_url
      }

      if current_filter == "comments"
        params[:hide_view_mode_button] = true
      else
        params[:resources] = resources
      end

      params
    end

    def remote_url
      if controller_name == "account"
        refresh_activities_account_path
      elsif controller_name == "users"
        refresh_activities_user_path(user)
      end
    end
end
