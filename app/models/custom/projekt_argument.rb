class ProjektArgument < ApplicationRecord
  include Imageable

  belongs_to :projekt

  validates :name, presence: true
  validates :position, presence: true
  validates :note, presence: true
  # validates :image, presence: true, on: :create

  default_scope { order(created_at: :asc) }

  scope :sort_by_all, -> {
    all
  }

  scope :pro, -> {
    where(pro: true)
  }

  scope :cons, -> {
    where.not(pro: true)
  }
end
