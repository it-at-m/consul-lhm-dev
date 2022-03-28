class AddOnBehalfOfToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :proposals, :on_behalf_of, :string
    add_column :debates, :on_behalf_of, :string
  end
end
