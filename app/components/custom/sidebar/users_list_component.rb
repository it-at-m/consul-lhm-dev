class Sidebar::UsersListComponent < ApplicationComponent
  def initialize(users:, hide_count: false)
    @users = users
    @hide_count = hide_count
  end
end
