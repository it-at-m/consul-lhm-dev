class AddKeycloakLinkToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :keycloak_link, :string
  end
end
