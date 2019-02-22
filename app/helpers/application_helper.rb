module ApplicationHelper
  def google_maps_link(event, title='Find me on Google maps')
    link_to raw("<em>#{title}</em>"), sanitize("https://www.google.com/maps/search/#{CGI.escape("#{event.street}, #{event.zipcode} #{event.city}")}"), rel: "nofollow", :class => 'google_maps', target: '_blank'
  end

  def google_maps_amp_link(event, title='Find me on Google maps')
    link_to raw("<em>#{title}</em>"), sanitize("https://www.google.com/maps/search/#{CGI.escape("#{event.street}, #{event.zipcode} #{event.city}")}")
  end
end
