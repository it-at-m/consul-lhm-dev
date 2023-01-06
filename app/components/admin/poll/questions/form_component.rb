class Admin::Poll::Questions::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :question, :url

  #delegate :can?, to: :helpers
  delegate :can?, :ck_editor_class, :current_user, to: :helpers #custom

  def initialize(question, url:)
    @question = question
    @url = url
  end

  private

    def select_options
      Poll.all.select { |poll| can?(:create, Poll::Question.new(poll: poll)) }.map do |poll|
        [poll.name, poll.id]
      end
    end
end
