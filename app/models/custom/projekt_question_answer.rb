class ProjektQuestionAnswer < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :question, class_name: "ProjektQuestion", foreign_key: "projekt_question_id" #, counter_cache: true #, inverse_of: :answers,
  belongs_to :question_option, class_name: "ProjektQuestionOption", foreign_key: "projekt_question_option_id", counter_cache: "answers_count" #, inverse_of: :answers
  belongs_to :user #, inverse_of: :projekt_question_answers

  # validates :question, presence: true, uniqueness: { scope: :user_id }
  # validates :question_option, presence: true
  # validates :user, presence: true
end
