module Story

  # Returns the URL for the story at Pivotal Tracker.
  def story_url(story_id)
    "https://www.pivotaltracker.com/story/show/#{story_id}"
  end

  # Returns the ids of delivered stories found in the given text.
  def delivered_ids(text)
    delivered  = text.scan(/\[Deliver(?:s|ed) (.*?)\]/).flatten
    # Handle multiple ids, i.e., '[Delivers #<id 1> #<id 2>]'
    delivered.inject([]) do |ids, element|
      ids.concat(element.scan(/[0-9]{8,}/).flatten)
      ids
    end.uniq
  end
end