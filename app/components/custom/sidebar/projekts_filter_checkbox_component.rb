class Sidebar::ProjektsFilterCheckboxComponent < ApplicationComponent
  delegate :projekt_filter_resources_name, to: :helpers
  attr_reader :f, :projekt

  def initialize(
    f:,
    projekt:,
    scoped_projekt_ids:,
    group:,
    all_resources:,
    current_projekt: nil
  )
    @f = f
    @projekt = projekt
    @scoped_projekt_ids = scoped_projekt_ids
    @group = group
    @all_resources = all_resources
    @current_projekt = current_projekt
  end

	private

  def resource_count
    projekt_ids_to_count = projekt.all_children_ids.unshift(projekt.id) & @scoped_projekt_ids

    @all_resources.where( projekt: projekt_ids_to_count ).count
  end

  def selectable_children
    projekt.children.select{ |projekt| ( projekt.all_children_ids.unshift(projekt.id) & @scoped_projekt_ids ).any? }
  end

  def label_class
    if checkbox_checked
      'label-selected'
    else
      'label_regular'
    end
  end

  def checkbox_checked
    selected_projekts_ids = params[:filter_projekt_ids]
    selected_projekts_ids && projekt.id.to_s.in?(selected_projekts_ids)
  end
end
