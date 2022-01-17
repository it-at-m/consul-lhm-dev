class Shared::CommentsFormComponent < ApplicationComponent
  attr_reader :record

  def initialize(record)
    @record = record
  end

end
