class DeficiencyReport::Status < ApplicationRecord
  include Iconable

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable

  has_many :deficiency_reports, foreign_key: :deficiency_report_status_id

  def self.create_default_objects
    return if DeficiencyReport::Status.count > 0
    DeficiencyReport::Status.create(
      title: 'Offen',
      color: 'red',
      icon: 'hourglass-start'
    )
    DeficiencyReport::Status.create(
      title: 'In Bearbeitung',
      color: 'orange',
      icon: 'hourglass-half'
    )
    DeficiencyReport::Status.create(
      title: 'Erledigt',
      color: 'green',
      icon: 'hourglass-end'
    )
  end

  def safe_to_destroy?
    !deficiency_reports.exists?
  end

  def self.order_statuses(ordered_array)
    ordered_array.each_with_index do |status_id, order|
      find(status_id).update_column(:given_order, (order + 1))
    end
  end
end
