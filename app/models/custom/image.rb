require_dependency Rails.root.join("app", "models", "image").to_s

class Image < ApplicationRecord

  private

    def validate_image_dimensions
      if attachment_of_valid_content_type?
        return true if imageable_class == Widget::Card
        return true if imageable_class == SiteCustomization::Page

        dimensions = Paperclip::Geometry.from_file(attachment.queued_for_write[:original].path)
        min_width = Setting["uploads.images.min_width"].to_i
        min_height = Setting["uploads.images.min_height"].to_i
        errors.add(:attachment, :min_image_width, required_min_width: min_width) if dimensions.width < min_width
        errors.add(:attachment, :min_image_height, required_min_height: min_height) if dimensions.height < min_height
      end
    end
end
