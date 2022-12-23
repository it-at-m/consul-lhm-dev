class Shared::SelectableSettingComponent < ApplicationComponent
  def initialize(selectable_setting:, options:, tab: nil)
    @selectable_setting = Setting.find_by(key: "selectable_setting.#{selectable_setting}")
    @options = options
    @tab = tab
  end

  private

    def render?
      @selectable_setting.present?
    end
end
