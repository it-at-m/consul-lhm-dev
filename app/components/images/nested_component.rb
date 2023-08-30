class Images::NestedComponent < ApplicationComponent
  attr_reader :f, :image_fields

  def initialize(f, image_fields: :image, block_id: "nested-image")
    @f = f
    @image_fields = image_fields
    @block_id = block_id # for uniqueness custom
  end

  private

    def imageable
      f.object
    end

    def note
      t "images.form.note", accepted_content_types: Image.humanized_accepted_content_types,
        max_file_size: Image.max_file_size
    end
end
