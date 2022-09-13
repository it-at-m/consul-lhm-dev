class CreateProjektOverviewSpecialProjekt < ActiveRecord::Migration[5.2]
  def up
    Projekt.find_or_create_by(
      name: 'Overview page',
      special_name: 'projekt_overview_page',
      special: true
    )
  end
end
