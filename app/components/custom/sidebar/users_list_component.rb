class Sidebar::UsersListComponent < ApplicationComponent
  def initialize(users:)
    @users = users
  end
end
