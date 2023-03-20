class AddRegisteredAddressGroupingRestrictionToProjektPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_phases, :registered_address_grouping_restriction, :string, default: ""
    add_column :projekt_phases, :registered_address_grouping_restrictions, :jsonb, null: false, default: {}

    add_index :projekt_phases, :registered_address_grouping_restrictions, using: "gin",
      name: "index_p_phases_on_ra_grouping_restrictions"
  end
end
