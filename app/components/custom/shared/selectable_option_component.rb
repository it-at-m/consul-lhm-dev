class Shared::SelectableOptionComponent < ApplicationComponent
  def initialize(selectable_option, options)
    @selectable_option = Setting.find_by(key: "selectable_option.#{selectable_option}")
    @options = options
  end

  private

    def render?
      @selectable_option.present?
    end
end
