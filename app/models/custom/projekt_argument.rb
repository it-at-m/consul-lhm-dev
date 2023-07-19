class ProjektArgument < ApplicationRecord
  include Imageable

  belongs_to :old_projekt, class_name: "Projekt", foreign_key: "projekt_id" # TODO: remove column after data migration con1538

  belongs_to :projekt_phase
  delegate :projekt, to: :projekt_phase

  validates :name, presence: true
  validates :position, presence: true
  validates :note, presence: true
  # validates :image, presence: true, on: :create
  validates :projekt_phase, presence: true

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
