xml.instruct! :xml, :version=>'1.0'
xml.sitemapindex('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9'){
  xml.sitemap {
    xml.loc(sitemap_city_root_url(host: @new_request_host, area: @current_area.domain))
  }

  (@events_count.to_f / 1000).ceil.times do |count|
    count = count + 1
    xml.sitemap {
      xml.loc(sitemap_city_show_url(host: @new_request_host, area: @current_area.domain, page: count))
      xml.lastmod(@array[count].xmlschema)
    }
  end
}
