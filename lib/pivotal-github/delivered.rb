module Delivered

  # Returns the ids of delivered stories.
  def delivered_ids(text)
    delivered  = text.scan(/\[Deliver(?:s|ed) (.*?)\]/).flatten
    # Handle multiple ids, i.e., '[Delivers #<id 1> #<id 2>]'
    delivered.inject([]) do |ids, element|
      ids.concat(element.scan(/[0-9]{8,}/).flatten)
      ids
    end
  end
end