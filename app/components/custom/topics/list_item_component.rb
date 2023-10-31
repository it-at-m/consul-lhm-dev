# frozen_string_literal: true

class Topics::ListItemComponent < ApplicationComponent
  attr_reader :topic

  def initialize(topic:)
    @topic = topic
  end

  def component_attributes
    {
      resource: @topic,
      title: topic.title,
      description: topic.description,
      url: helpers.community_topic_path(topic.community, topic),
      date: topic.created_at,
      subline: "#{topic.comments_count} kommentare",
      image_placeholder_icon_class: "fa-users",
    }
  end
end
