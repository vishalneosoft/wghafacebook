xml.instruct! :xml, :version=>'1.0'
xml.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9'){

  xml.url {
    xml.loc(events_url(:host => @new_request_host, :area => @current_area.domain))
    xml.changefreq('hourly')
  }

  xml.url {
    xml.loc(future_events_url(:host => @new_request_host, :area => @current_area.domain))
    xml.changefreq('daily')
  }

  @array.keys.each do |date|
    next if @array[date].nil?
    xml.url {
      xml.loc(future_event_url(date: date.strftime("%d.%m.%Y") , host: @new_request_host, :area => @current_area.domain))
      xml.changefreq('hourly')
      xml.lastmod(@array[date].xmlschema)
    }
  end
}
