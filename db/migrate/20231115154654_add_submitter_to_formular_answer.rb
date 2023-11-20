class AddSubmitterToFormularAnswer < ActiveRecord::Migration[5.2]
  def change
    add_column :formular_answers, :submitter_id, :bigint
    add_column :formular_answers, :original_submitter_email, :string
  end
end
