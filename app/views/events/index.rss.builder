# https://www.codingfish.com/blog/129-how-to-create-rss-feed-rails-4-3-steps
  xml.instruct! :xml, :version => "1.0"
  xml.rss :version => "2.0", 'xmlns:atom': 'http://www.w3.org/2005/Atom' do
    xml.channel do
      xml.title "Was geht heute ab in #{@current_area.name}?"
      xml.description "Partys & Konzerte - Ausgehen im Nachtleben von #{@current_area.name}. Wir zeigen dir auf www.wgha.de wohin man abends ausgehen kann."
      xml.link area_url
      xml.language "de"
      if @events.blank?
        xml.lastBuildDate Time.zone.now.to_s(:rfc822)
      else
        xml.lastBuildDate @events.map(&:updated_at).max.to_s(:rfc822)
      end
      xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => area_url(format: 'rss')

      for event in @events
        xml.item do
          xml.title event.name
          xml.pubDate event.created_at.to_s(:rfc822)
          xml.link event_url(uuid: event.uuid)
          xml.guid event_url(uuid: event.uuid)
          xml.description t(:meta_description_event, :area => @current_area.name, :event_name => event.name, :date => event.start_time.strftime("%d.%m.%Y"), :location => event.location, :scope => 'helpers.events', extension: 'de')
        end
      end
    end
  end
