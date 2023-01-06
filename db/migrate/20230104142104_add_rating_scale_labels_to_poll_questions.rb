class AddRatingScaleLabelsToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Poll::Question.add_translation_fields! min_rating_scale_label: :string, max_rating_scale_label: :string
      end

      dir.down do
        remove_column :poll_question_translations, :min_rating_scale_label, :max_rating_scale_label
      end
    end
  end
end
