class AddPostalCodesToGeozones < ActiveRecord::Migration[5.2]
  def change
    add_column :geozones, :postal_codes, :string
  end
end
