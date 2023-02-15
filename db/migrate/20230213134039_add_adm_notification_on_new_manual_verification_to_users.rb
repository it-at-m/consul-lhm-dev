class AddAdmNotificationOnNewManualVerificationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :adm_email_on_new_manual_verification, :boolean, default: false
  end
end
