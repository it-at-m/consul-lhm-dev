class EmailActivity < ApplicationRecord
  belongs_to :actionable, -> { with_hidden }, polymorphic: true

  def self.log(email, actionable)
    create!(email: email, actionable: actionable)
  end
end
