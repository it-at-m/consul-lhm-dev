# frozen_string_literal: true

class Projekts::ProjektEvents::List < ApplicationComponent
  attr_reader :projekt_events

  def initialize(projekt_events:, show_projekt_link: false)
    @projekt_events = projekt_events
    @show_projekt_link = show_projekt_link
  end

  def event_component_class
    @event_component_class ||=
      if Setting.new_design_enabled?
        Projekts::ProjektEvents::ListItemNewComponent
      else
        Projekts::ProjektEvents::ListItem
      end
  end
end
