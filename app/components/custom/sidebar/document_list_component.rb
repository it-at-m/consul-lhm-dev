class Sidebar::DocumentListComponent < ApplicationComponent
  def initialize(documents:)
    @documents = documents
  end
end
