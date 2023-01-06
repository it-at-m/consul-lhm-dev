class ModalNotification < ApplicationRecord
  translates :title, :html_content
  include Globalizable

  scope :active, ->(timestamp = Time.zone.today) {
    where("? BETWEEN active_from AND active_to", timestamp)
      .order(created_at: :desc)
  }

  def self.current
    active.first
  end
end
