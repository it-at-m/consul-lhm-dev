class Shared::ToggleAttributeComponent < ApplicationComponent
  def initialize(resource, attribute, path, options = {})
    @resource = resource
    @attribute = attribute
    @path = path
    @options = options
  end

  def button_text
    @resource.send(@attribute) ? t("custom.boolean.yes") : t("custom.boolean.no")
  end
end
