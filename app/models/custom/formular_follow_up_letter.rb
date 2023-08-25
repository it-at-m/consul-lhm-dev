class FormularFollowUpLetter < ApplicationRecord
  belongs_to :formular
  has_many :recipients, dependent: :destroy,
    class_name: "FormularFollowUpLetterRecipient", inverse_of: :formular_follow_up_letter
  has_many :formular_answers, through: :recipients
end
