class FormularAnswerDocument < ApplicationRecord
  include Attachable

  belongs_to :formular_answer
  validates :title, presence: true

  scope :admin, -> { where(admin: true) }

  def self.humanized_accepted_content_types
    Setting.accepted_content_types_for("documents").join(", ")
  end

  def humanized_content_type
    attachment_content_type.split("/").last.upcase
  end

  def max_file_size
    3
  end

  def accepted_content_types
    ["application/pdf"]
  end

  def association_class
    self.class
  end

  private

    def association_name
      :formular_answer
    end
end
