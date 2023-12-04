class CreateUnregisteredNewsletterRecievers < ActiveRecord::Migration[5.2]
  def change
    create_table :unregistered_newsletter_subscribers do |t|
      t.string :email
      t.boolean :confirmed, default: false
      t.string :confirmation_token, uniq: true
      t.string :unsubscribe_token, uniq: true
      t.timestamps
    end
  end
end
