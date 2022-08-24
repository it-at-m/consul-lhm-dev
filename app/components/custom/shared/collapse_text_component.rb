class Shared::CollapseTextComponent < ApplicationComponent
  renders_one :inner_content

  def initialize(size: :normal, color: :gray)
    @size = size
    @color = color
  end

  def collapse_class
    class_name = ''

    class_name +=
      case @size
      when :normal
        '-normal'
      when :small
        '-small'
      end

    class_name +=
      case @color
      when :gray
        ' -gray'
      when :white
        ' -white'
      end

    class_name
  end
end
