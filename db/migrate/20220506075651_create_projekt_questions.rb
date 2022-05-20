class CreateProjektQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_questions do |t|
      t.text :title
      t.integer :answers_count, default: 0
      t.integer :comments_count, default: 0
      t.integer :author_id, default: 0

      t.datetime :hidden_at, index: true

      t.timestamps
      t.references :projekt, index: true
    end

    create_table :projekt_question_translations do |t|
      t.references :projekt_question, index: true
      t.string :locale, null: false, index: true
      t.text :title
      t.datetime :hidden_at
      t.timestamps null: false
    end

    create_table :projekt_question_options do |t|
      t.references :projekt_question, index: true
      t.integer :answers_count, default: 0

      t.datetime :hidden_at, index: true

      t.timestamps null: false
    end

    create_table :projekt_question_option_translations do |t|
      t.references :projekt_question_option, index: false
      t.string :locale, null: false
      t.string :value
      t.datetime :hidden_at
      t.timestamps null: false
    end

    add_index :projekt_question_option_translations, :projekt_question_option_id, name: 'option_projekt_question_option_id'

    create_table :projekt_question_answers do |t|
      t.references :projekt_question, index: true
      t.references :projekt_question_option, index: true
      t.references :user, index: true

      t.datetime :hidden_at, index: true

      t.timestamps null: false
    end
  end
end
