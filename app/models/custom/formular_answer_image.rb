class FormularAnswerImage < ApplicationRecord
  include Attachable

  def self.styles
    {
      large: { resize: "x#{Setting["uploads.images.min_height"]}" }
    }
  end

  belongs_to :formular_answer
  validates :title, presence: true
  # validate :validate_title_length

  def self.max_file_size
    5
  end

  def self.accepted_content_types
    ["image/jpeg", "image/png"]
  end

  def self.humanized_accepted_content_types
    "jpg, png"
  end

  def max_file_size
    self.class.max_file_size
  end

  def accepted_content_types
    self.class.accepted_content_types
  end

  def variant(style)
    if style
      attachment.variant(self.class.styles[style])
    else
      attachment
    end
  end

  def attached?
    attachment.attached?
  end

  def association_class
    self.class
  end


  private

    def association_name
      :formular_answer
    end
end
