class Sidebar::CategoriesCardComponent < ApplicationComponent
  def initialize(categories:, **options)
    @categories = categories
    @options = options
  end
end
