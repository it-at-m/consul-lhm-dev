module StyleHelper
  def pick_text_color(background_color)
    return '#000000' if background_color.nil?
    return '#000000' unless background_color.match?(/\A#[\d, a-f, A-F]{6}\Z/)

    transformed_color = background_color.match(/^#(..)(..)(..)$/).captures.map do |n| 
      n = n.hex.to_f
      n/255 <= 0.03928 ? n/255/12.92 : ((n/255+0.055)/1.055)**2.4
    end

    background_relative_luminance = transformed_color[0] * 0.2126 +
      transformed_color[1] * 0.7152 +
      transformed_color[2] * 0.0722 

    white_contrast_ratio = (1 + 0.05) / (background_relative_luminance + 0.05)
    black_contrast_ratio = (background_relative_luminance + 0.05) / (0 + 0.05)

    white_contrast_ratio > black_contrast_ratio ? "#ffffff" : "#000000"
  end
end
