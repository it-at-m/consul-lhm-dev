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

  def self.scoped_projekt_ids_for_footer(projekt)
		projekt.top_parent.all_children_projekts.unshift(projekt.top_parent).
      pluck(:id)
  end
end
