class ProjektEvent < ApplicationRecord
  belongs_to :projekt

  validates :title, presence: true
  validates :datetime, presence: true

  default_scope { order(datetime: :asc) }

  scope :sort_by_all, -> {
    all
  }

  scope :sort_by_incoming, -> {
    where('datetime > ?', Time.now)
  }

  scope :sort_by_past, -> {
    where('datetime < ?', Time.now)
  }

  def self.base_selection(scoped_projekt_ids = Projekt.ids)
    where(projekt_id: scoped_projekt_ids)
  end
end
