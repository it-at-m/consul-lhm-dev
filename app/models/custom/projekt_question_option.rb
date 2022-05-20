class ProjektQuestionOption < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :value, touch: true
  include Globalizable

  belongs_to :question, class_name: "ProjektQuestion", foreign_key: "projekt_question_id" #, inverse_of: :question_options
  has_many :answers, class_name: "ProjektQuestionAnswer", foreign_key: "projekt_question_id", dependent: :destroy #, inverse_of: :question

  validates_translation :value, presence: true
end
