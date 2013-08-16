module Story

  # Returns the URL for the story at Pivotal Tracker.
  def story_url(story_id)
    "https://www.pivotaltracker.com/story/show/#{story_id}"
  end

  # Returns the ids of delivered stories found in the given text.
  def delivered_ids(text)
    delivered = text.scan(/\[Deliver(?:s|ed) (.*?)\]/).flatten
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
    delivered_ids(fast_log_delivered_text).uniq
  end

  def fast_log_delivered_text
    @delivered_text ||= `git log -E --grep '\\[Deliver(s|ed) #'`
  end

  # Returns the ids delivered since the last pull request.
  # We omit the ids of stories that have already been delivered by a
  # particular pull request, so that each new PR is only tagged with stories
  # delivered since the *last* PR.
  def delivered_ids_since_last_pr(text)
    delivered_ids(text) - pr_ids(text)
  end

  # Returns the ids included in previous pull requests.
  def pr_ids(text)
    text.scan(/\[Deliver(?:s|ed) #(.*?)\]\(https:\/\//).flatten.uniq
  end
end