class AddProjektToProposals < ActiveRecord::Migration[5.1]
  def change
    add_reference :proposals, :projekt, foreign_key: true
  end
end
