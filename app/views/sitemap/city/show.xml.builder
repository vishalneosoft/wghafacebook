xml.instruct! :xml, :version=>'1.0'
xml.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9'){

  for flyer in @flyers
    xml.url {
      xml.loc(event_url(area: flyer[1], uuid: flyer[0], host: @new_request_host))
      xml.changefreq('hourly')
      xml.lastmod(flyer[2].xmlschema)
    }
  end
}
