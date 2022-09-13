class AddProjektManagerToProjekt < ActiveRecord::Migration[5.2]
  def change
    add_reference :projekts, :projekt_manager, foreign_key: true
  end
end
