module OnBehalfOfSubmittable
  extend ActiveSupport::Concern

  def author_name
    on_behalf_of.presence || author.name
  end

  def author_initial
    if on_behalf_of.present?
      on_behalf_of.chars&.first&.upcase
    else
      author.first_letter_of_name
    end
  end
end
