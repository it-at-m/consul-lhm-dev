class Sidebar::CategoriesCardComponent < ApplicationComponent
  def initialize(categories:)
    @categories = categories
  end
end
