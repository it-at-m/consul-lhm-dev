class AddAdminEmailsOnNewEventsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :adm_email_on_new_comment, :boolean, default: false
    add_column :users, :adm_email_on_new_proposal, :boolean, default: false
    add_column :users, :adm_email_on_new_debate, :boolean, default: false
    add_column :users, :adm_email_on_new_deficiency_report, :boolean, default: false
  end
end
