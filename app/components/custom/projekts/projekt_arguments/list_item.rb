# frozen_string_literal: true

class Projekts::ProjektArguments::ListItem < ApplicationComponent
  attr_reader :projekt_argument

  def initialize(projekt_argument:)
    @projekt_argument = projekt_argument
  end
end
