class Sidebar::ProjektsFilterCheckboxComponent < ApplicationComponent
  delegate :projekt_filter_resources_name, to: :helpers

  def initialize(f, projekt, group, all_resources, current_projekt=nil)
    @f = f
    @projekt = projekt
    @current_projekt = current_projekt
    @group = group
    @all_resources = all_resources
  end

	private

  def f
    @f
  end

  def projekt
    @projekt
  end

  def resource_count
    @all_resources.where(projekt: projekt.selectable_tree_ids(projekt_filter_resources_name, @group)).count
  end

  def selectable_children
    if @group == 'active'
      @projekt.children.with_order_number.selectable_in_sidebar_current(projekt_filter_resources_name)
    elsif @group == 'archived'
      @projekt.children.with_order_number.selectable_in_sidebar_expired(projekt_filter_resources_name)
    end
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
