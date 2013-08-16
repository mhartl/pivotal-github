module Story

  # Returns the URL for the story at Pivotal Tracker.
  def story_url(story_id)
    "https://www.pivotaltracker.com/story/show/#{story_id}"
  end

  # Returns the ids of delivered stories found in the given text.
  # We omit the ids of stories that have already been delivered by a
  # particular pull request, so that each new PR is only tagged with stories
  # delivered since the *last* PR.
  def delivered_ids(text)
    # Match '[Delivers #6283185]' but *not* '[Delivers #6283185]('.
    # The latter is the case for deliveries included as part of pull request
    # commits, which include lines of the form
    # [Delivers #6283185](https://www.pivotaltracker.com/story/show/6283185)
    delivered_not_in_pr = /\[Deliver(?:s|ed) (.*?)\](?:$|[^(])/
    delivered = text.scan(delivered_not_in_pr).flatten
    # Handle multiple ids, i.e., '[Delivers #<id 1> #<id 2>]'
    delivered.inject([]) do |ids, element|
      ids.concat(element.scan(/[0-9]{8,}/).flatten)
      ids
    end.uniq
  end

  # Returns the ids of delivered stories according to the Git log.
  # These ids are of the form [Delivers #<story id>] or
  # [Delivers #<story id> #<another story id>]. The difference is handled
  # by the delivered_ids method.
  def git_log_delivered_story_ids
    delivered_text = `git log -E --grep '\\[Deliver(s|ed) #'`
    delivered_ids(delivered_text).uniq
  end
end