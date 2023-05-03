class Admin::IndividualGroupValues::RelatedUsersComponent < ApplicationComponent
  attr_reader :related_users, :individual_group_value, :options

  def initialize(related_users, individual_group_value, **options)
    @related_users = related_users
    @individual_group_value = individual_group_value
    @options = options
  end

  private

    def add_user_path(related_user)
      {
        controller: "admin/individual_group_values",
        action: :add_user,
        user_id: related_user.id
      }
    end
end
