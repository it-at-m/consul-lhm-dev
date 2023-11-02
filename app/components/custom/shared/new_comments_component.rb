class Shared::NewCommentsComponent < ApplicationComponent
  attr_reader :record, :comment_tree
  delegate :current_user, :current_order, :locale_and_user_status, :commentable_cache_key, to: :helpers

  def initialize(
    record,
    comment_tree,
    show_title: true,
    remote_url: nil,
    anchor: "comments"
  )
    @record = record
    @comment_tree = comment_tree
    @show_title = show_title
    @remote_url = remote_url
    @anchor = anchor
  end

  private

  def show_filter?
    return false if record.is_a?(ProjektQuestion)

    !(comment_tree.root_comments.where(hidden_at: nil).count < 2)
  end

  def cache_key
    [
      locale_and_user_status,
      current_order,
      commentable_cache_key(record),
      comment_tree.comments,
      comment_tree.comment_authors,
      record.comments_count
    ]
  end

  def cache_key
    [
      locale_and_user_status,
      current_order,
      commentable_cache_key(record),
      comment_tree.comments,
      comment_tree.comment_authors,
      record.comments_count,
      record_specific_keys,
      Comment.body_max_length
    ].flatten
  end

  def record_specific_keys
    keys = []
    add_phase_specific_keys(keys) if ["Proposal", "Debate"].include?(record.class.name) && record.projekt.present?
    add_poll_specific_keys(keys) if record.class.name == "Poll"
    add_projekt_page_specific_keys(keys) if record.class.name == "Projekt"
    keys
  end

  def add_phase_specific_keys(keys)
    keys.push(record.projekt_phase)
    keys.push(record.projekt_phase.geozone_restrictions)
    keys.push(helpers.change_of_current_state(record.projekt_phase.start_date, record.projekt_phase.end_date))
    keys.push(helpers.change_of_current_state(record.projekt.total_duration_start, record.projekt.total_duration_end))
  end

  def add_poll_specific_keys(keys)
    keys.push(record.geozones)
    keys.push(helpers.change_of_current_state(record.starts_at, record.ends_at))
    keys.push(record)
  end

  def add_projekt_page_specific_keys(keys)
    keys.push(record)
    keys.push(record.page)
    keys.push(record.projekt_settings)
    keys.push(record.comment_phase)
    keys.push(record.comment_phase.geozone_restrictions)
    keys.push(helpers.change_of_current_state(record.comment_phase.start_date, record.comment_phase.end_date))
  end

  def pagination_links
    if params[:projekt_phase_id].present?
      paginate comment_tree.root_comments, params: { action: "projekt_phase_footer_tab" }, remote: true
    else
      paginate comment_tree.root_comments, params: { anchor: "comments" }
    end
  end
end
