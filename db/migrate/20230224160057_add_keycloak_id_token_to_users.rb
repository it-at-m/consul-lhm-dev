class AddKeycloakIdTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :keycloak_id_token, :text, default: ""
  end
end
