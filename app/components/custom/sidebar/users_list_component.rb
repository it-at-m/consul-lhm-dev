class Sidebar::UsersListComponent < ApplicationComponent
  def initialize(users:, hide_count: false, show_resources_count: false)
    @users = users
    @hide_count = hide_count
    @show_resources_count = show_resources_count
  end

  private

    def projekts_count
      Projekt.regular.index_order_all.count
    end

    def proposals_count
      Proposal.for_public_render.count
    end

    def comments_count
      Comment.count
    end
end
