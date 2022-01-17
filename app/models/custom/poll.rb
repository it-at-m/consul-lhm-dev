require_dependency Rails.root.join("app", "models", "poll").to_s

class Poll < ApplicationRecord
  include Taggable

  scope :last_week, -> { where("polls.created_at >= ?", 7.days.ago) }

  belongs_to :projekt, optional: true
  has_many :geozone_affiliations, through: :projekt

  scope :with_active_projekt,  -> { joins(:projekt).merge(Projekt.active) }

  def answerable_by?(user)
    user &&
      !user.organization? &&
      user.level_three_verified? &&
      current? &&
      (!geozone_restricted || ( geozone_restricted && geozone_ids.blank? && user.geozone.present? ) || (geozone_restricted && geozone_ids.include?(user.geozone_id)))
  end

  def comments_allowed?(user)
    answerable_by?(user)
  end

  def find_or_create_stats_version
    if !expired? && stats_version && stats_version.created_at.to_date != Date.today.to_date
      stats_version.destroy
    end
    super
  end

  def safe_to_delete_answer?
    voters.count == 0
  end

  def delete_voter_participation_if_no_votes(user, token)
    poll_answer_count_by_current_user = questions.inject(0) { |sum, question| sum + question.answers.where(author: user).count }
    if poll_answer_count_by_current_user == 0
      Poll::Voter.find_by!(user: user, poll: self, origin: "web", token: token).destroy
    end
  end
end
