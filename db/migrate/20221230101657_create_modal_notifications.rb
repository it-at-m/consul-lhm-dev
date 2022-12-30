class CreateModalNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :modal_notifications do |t|
      t.date :active_from
      t.date :active_to

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        ModalNotification.create_translation_table! title: :string, html_content: :text
      end

      dir.down do
        ModalNotification.drop_translation_table!
      end
    end
  end
end
