class Admin::LivesubmitCheckbox::Component < ApplicationComponent
  def initialize(url:, resource_name: , attribute_name:, id:, current_value:)
    @url = url
    @resource_name = resource_name
    @attribute_name = attribute_name
    @id = id
    @current_value = current_value
  end

  def options
    {
      data: { disable_with: text },
      "aria-pressed": (@current_value.presence || false).to_s
    }
  end

  private

  def field_name
    "#{@resource_name}[#{@attribute_name}]"
  end

  def id_field_name
    "#{@resource_name}[id]"
  end

  def text
    if enabled?
      enabled_text
    else
      disabled_text
    end
  end

  def enabled_text
    t("shared.yes")
  end

  def disabled_text
    t("shared.no")
  end

  def enabled?
    @current_value
  end
end
