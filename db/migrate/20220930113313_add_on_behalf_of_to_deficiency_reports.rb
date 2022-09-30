class AddOnBehalfOfToDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    add_column :deficiency_reports, :on_behalf_of, :string
  end
end
