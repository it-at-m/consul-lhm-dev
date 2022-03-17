class Sidebar::ProjektsFilterRadioComponent < ApplicationComponent
  delegate :projekt_filter_resources_name, to: :helpers
  attr_reader :f, :projekt, :group

  def initialize(f, projekt, group, all_resources)
    @f = f
    @projekt = projekt
    @group = group
    @all_resources = all_resources
  end

	private

  def selectable_children
    if group == 'active'
      projekt.children.select { |p| p.current? && p.send("#{projekt_filter_resources_name}").present? }
    elsif group == 'archived'
      projekt.children.select { |p| p.expired? && p.send("#{projekt_filter_resources_name}").present? }
    end
  end

  def label_class
    if radio_button_selected
      'label-selected'
    else
      'label_regular'
    end
  end

  def radio_button_selected
    projekt.id == params[:filter_projekt_id]
  end
end
