class UploadController < ApplicationController
  force_ssl if Rails.env.production?

  def index
  
    options = {

	   :phantomjs_options => ["--proxy=de112.nordvpn.com:80", "--proxy-auth=torsten.lankau@lankau.net:yAxdS2klOBcW3s5iOfTt"]
	   
   }

   
    respond_to :html
  end

  def create_event
    @token = IdToken.new(params)

    if !@token.valid?
      # @token.errors.add('sdf', 'is an invalid format')
      return render :index
    end

    # access_tokens = [
    #   '*|*'
    # ]

    # batch_request = []
    # batch_request << "{'method':'GET', 'relative_url':'#{@token.token}?fields=id,place,name,start_time,description,timezone,cover'}"

    # request = Typhoeus::Request.new(
    #   "https://graph.facebook.com/v2.9/",
    #   connecttimeout: 60,
    #   method: :post,
    #   params: {
    #     access_token: access_tokens.sample,
    #     batch: "[#{batch_request.join(',')}]" }
    #     )

    # request.run
    # response = request.response

    # begin
    #   results = JSON.parse(response.body)
    # rescue
    #   @token.errors.add(:base, 'There was a problem with the event. Check the setting on Facebook and try again later.')
    #   return render :index
    # end

    # result = results.first
    result = parse_event_details(session['access_token'], @token.token)

    # can never be a 304 since we do not ask for that
    begin
      result['code'].to_i != 200
    rescue
      @token.errors.add(:base, "Your link is currently not available on Facebook. Please check the link and try again later.")
      return render :index
    end

	  if result['code'].to_i != 200
      @token.errors.add(:base, 'The event could not be uploaded because you are not the event owner or the event details are incorrect.')
      return render :index
    end
	
    if result['privacy'] == "closed"
      @token.errors.add(:base, 'The event is not marked as public. No age restrictions or similar settings must be activated for the event.')
      return render :index
    end

    # begin
    #   result = JSON.parse(result['body'])
    # rescue
    #   @token.errors.add(:base, 'Your link is currently not available on Facebook. Please check the link and try again later.')
    #   return render :index
    # end

    if result['place'].blank?
      @token.errors.add(:base, 'No age restrictions or similar settings must be enabled for the event, otherwise Facebook will prevent the data from being retrieved or the location of the event is not correctly entered. Learn how to create a place on Facebook: https://www.facebook.com/help/iphone-app/175921872462772?helpref=platform_switcher&ref=platform_switcher . Create your location as a "Place" on Facebook and try again.')
      return render :index
    end

    if result['place']['location'].blank?
      @token.errors.add(:base, 'The location of the event was not entered correctly, please enter proper location. Here''s how to create a "place" on Facebook: https://www.facebook.com/help/iphone-app/175921872462772?helpref=platform_switcher&ref=platform_switcher. Create your location as "Place" on Facebook and try again.')
      return render :index
    end

    if result['place']['location']['city'].blank?
      @token.errors.add(:base, 'No age restrictions or similar settings must be enabled for the event, otherwise Facebook will prevent the data from being retrieved or the location of the event is not correctly entered. Learn how to create a place on Facebook: https://www.facebook.com/help/iphone-app/175921872462772?helpref=platform_switcher&ref=platform_switcher . Create your location as a "Place" on Facebook and try again.')
      return render :index
    end

    if !result['place']['location']['country'].blank?
      if !result['place']['location']['country'].match(/Germany|Deutschland/)
        @token.errors.add(:base, 'Only events from Germany, Austria and Switzerland are included')
        return render :index
      end
    end

    if result['cover'].blank? || result['cover']['source'].blank?
      @token.errors.add(:base, 'We can\'t find a picture of the event on Facebook. Add a picture to Facebook and try again.')
      return render :index
    end

    if !Typhoeus.head(result['cover']['source']).success?
      @token.errors.add(:base, 'There is a problem downloading the image of the event. Check the picture on Facebook and try again.')
      return render :index
    end

    # Try to find Token in current events
    event              = Event.find_by(eid: @token.token) || Event.new
    event.name         = result['name'].split('@').first if result['name']
    event.name         = event.name.strip if event.name
    event.location     = result['place']['name'] if result['place']
    event.eid          = @token.token
    event.website      = "https://www.facebook.com/events/#{@token.token}"

    existing_fb_event = Event.find_by(eid: event.eid)
    if existing_fb_event
      event.uuid = existing_fb_event.uuid
    else
      event.uuid = SecureRandom.uuid if event.uuid.blank?
    end

    begin
      event.description = result['description'] if result['description']
    rescue
      @token.errors.add(:base, 'There is a problem with the description text of the event. Check the description on Facebook and try again.')
      return render :index
    end

    if result['start_time']
      ffid_date             = DateTime.parse(result['start_time'])
      ffid_date             = ffid_date + 21.hours if ffid_date.strftime('%H:%M:%S') == '00:00:00'
      event.start_time      = ffid_date
    end

    if result['place'] && result['place']['location']
      event.street    = result['place']['location']['street'] if result['place']['location']['street']
      event.zipcode   = result['place']['location']['zip'] if result['place']['location']['zip']
      event.city      = result['place']['location']['city'] if result['place']['location']['city']
      event.country   = result['place']['location']['country'] if result['place']['location']['country']
    end

    event.area = City.find_by(name: event.city).area.domain if City.find_by(name: event.city)

    city_names = City.pluck(:name).join('|')
    if !result['place']['location']['city'].match(/\A(#{city_names})\z/)
      @token.errors.add(:base, "Events for the city  #{result['place']['location']['city']} cannot be accepted. All cities for which we support events can be found here: #{root_url(area: nil)}")
      return render :index
    end

    if event.country.blank? && !event.city.blank?
      event.country = 'UK'
    end

    # look out for block words
    for word in BlockWordTitle.all
      next if event.name.blank?

      if event.name.match(/#{word.word}/i)
        @token.errors.add(:base, "The following word in the event name prevents the event from being imported: #{word.word}. Change the event on Facebook and try again.")
        return render :index
      end
    end

    for word in BlockWordDescription.all
      next if event.description.blank?

      if event.description.match(/#{word.word}/i)
        @token.errors.add(:base, "The following word in the description prevents the event from being imported: #{word.word}. Change the event on Facebook and try again.")
        return render :index
      end
    end

    for word in BlockWordLocation.all
      next if event.location.blank?

      if event.location.match(/#{word.word}/i)
        @token.errors.add(:base, "The following word in the description prevents the event from being imported: #{word.word}. Change the event on Facebook and try again.")
        return render :index
      end
    end

    #   # lock out for doubles
    if event.location
      candidate_count = Event.where.not(id: event.id).where(city: event.city).where('start_time > ?', (event.start_time - 30.minutes)).where('start_time < ?', (event.start_time + 30.minutes)).where("location like ?", "%#{event.location}%").count

      if candidate_count > 0
        @candidate = Event.where.not(id: event.id).where(city: event.city).where('start_time > ?', (event.start_time - 30.minutes)).where('start_time < ?', (event.start_time + 30.minutes)).where("location like ?", "%#{event.location}%").first
        @token.errors.add(:base, "There is already an event in this location on the same day.")
        return render :index
      end
    end

    if event.street
      candidate_count = Event.where.not(id: event.id).where(city: event.city).where('start_time > ?', (event.start_time - 30.minutes)).where('start_time < ?', (event.start_time + 30.minutes)).where("street like ?", "%#{event.street}%").count

      if candidate_count > 0
        @candidate = Event.where.not(id: event.id).where(city: event.city).where('start_time > ?', (event.start_time - 30.minutes)).where('start_time < ?', (event.start_time + 30.minutes)).where("street like ?", "%#{event.street}%").first
        @token.errors.add(:base, "There is already an event in this location on the same day.")
        return render :index
      end
    end

    # blocks fetches image from FB
    # TODO: Skip if images match hash sha1 and md5
    if result['cover'] && !result['cover']['source'].blank?
      if Typhoeus.head(result['cover']['source'].gsub("s720x720/", "")).success?
        event.facebook_image_url = result['cover']['source'].gsub("s720x720/", "") # s720x720 is the fb code for small image
      else
        event.facebook_image_url = result['cover']['source']
      end
      Dir.mkdir("#{Rails.root}/tmp/facebook_images") unless File.exist?("#{Rails.root}/tmp/facebook_images")
      response = Typhoeus::Request.get(event.facebook_image_url)
      tmp_path = Rails.root.to_s + "/tmp/facebook_images/#{SecureRandom.uuid()}"
      File.open(tmp_path, 'wb') {|file| file << response.body }
      image = Photo.new()
      image.file = Rack::Test::UploadedFile.new(tmp_path, '/image/jpg')
      image.event = event
    end

    begin
      if event.save
        @event = event
        return render :index
      else
        @token.errors.add(:base, "There was a problem with the event. Check the setting on Facebook and try again later. #{event.errors.full_messages}")
        return render :index
      end
    rescue => e
      @token.errors.add(:base, "Your link is not available on Facebook. Check the link and try again later.")
      return render :index
    end
  end

  def create
    @token = IdToken.new(params)

    if !@token.valid?
      # @token.errors.add('sdf', 'is an invalid format')
      return render :index
    end

    # access_tokens = [
    #   '*|*'
    # ]

    # batch_request = []
    # batch_request << "{'method':'GET', 'relative_url':'#{@token.token}?fields=id,place,name,start_time,description,timezone,cover'}"

    # request = Typhoeus::Request.new(
    #   "https://graph.facebook.com/v2.9/",
    #   connecttimeout: 60,
    #   method: :post,
    #   params: {
    #     access_token: access_tokens.sample,
    #     batch: "[#{batch_request.join(',')}]" }
    #     )

    # request.run
    # response = request.response

    # begin
    #   results = JSON.parse(response.body)
    # rescue
    #   @token.errors.add(:base, 'There was a problem with the event. Check the setting on Facebook and try again later.')
    #   return render :index
    # end

    # result = results.first

    result = parse_event_token(@token.token)

    # can never be a 304 since we do not ask for that
    begin
      result['code'].to_i != 200
    rescue
      @token.errors.add(:base, "Your link is currently not available on Facebook. Please check the link and try again later.")
      return render :index
    end

    if result['privacy'] == "closed"
      @token.errors.add(:base, 'The event is not marked as public. No age restrictions or similar settings must be activated for the event.')
      return render :index
    end

    # begin
    #   result = JSON.parse(result['body'])
    # rescue
    #   @token.errors.add(:base, 'Your link is currently not available on Facebook. Please check the link and try again later.')
    #   return render :index
    # end

	  # binding.pry
    if result['place'].blank?
      @token.errors.add(:base, 'No age restrictions or similar settings must be enabled for the event, otherwise Facebook will prevent the data from being retrieved or the location of the event is not correctly entered. Learn how to create a place on Facebook: https://www.facebook.com/help/iphone-app/175921872462772?helpref=platform_switcher&ref=platform_switcher . Create your location as a "Place" on Facebook and try again.')
      return render :index
    end

    if result['place']['location'].blank?
      @token.errors.add(:base, 'The location of the event was not entered correctly, please enter proper location. Here''s how to create a "place" on Facebook: https://www.facebook.com/help/iphone-app/175921872462772?helpref=platform_switcher&ref=platform_switcher. Create your location as "Place" on Facebook and try again.')
      return render :index
    end

    if result['place']['location']['city'].blank?
      @token.errors.add(:base, 'Es dürfen keine Alterbeschränkungen oder ähnliche Einstellungen für den Event aktiviert sein ansonsten verhindert Facebook das Abrufen der Daten oder der Ort des Events ist nicht richtig eingetragen. Hier erfährst du, wie du einen "Place" auf Facebook erstellst: https://www.facebook.com/help/iphone-app/175921872462772?helpref=platform_switcher&ref=platform_switcher . Erstelle deine Location als "Place" auf Facebook und probiere es nochmals.')
     return render :index
    end

    if !result['place']['location']['country'].blank?
      if !result['place']['location']['country'].match(/Germany|Deutschland/)
        @token.errors.add(:base, 'Es werden nur Events aus Deutschland, Östereich und der Schweiz aufgenommen.')
        return render :index
      end
    end

    if result['cover'].blank? || result['cover']['source'].blank?
      @token.errors.add(:base, 'We can\'t find a picture of the event on Facebook. Add a picture to Facebook and try again.')
      return render :index
    end

    if !Typhoeus.head(result['cover']['source']).success?
      @token.errors.add(:base, 'There is a problem downloading the image of the event. Check the picture on Facebook and try again.')
      return render :index
    end

    # Try to find Token in current events
    event              = Event.find_by(eid: @token.token) || Event.new
    event.name         = result['name'].split('@').first if result['name']
    event.name         = event.name.strip if event.name
    event.location     = result['place']['name'] if result['place']
    event.eid          = @token.token
    event.website      = "https://www.facebook.com/events/#{@token.token}"

    existing_fb_event = Event.find_by(eid: event.eid)
    if existing_fb_event
      event.uuid = existing_fb_event.uuid
    else
      event.uuid = SecureRandom.uuid if event.uuid.blank?
    end

    begin
      event.description = result['description'] if result['description']
    rescue
      @token.errors.add(:base, 'There is a problem with the description text of the event. Check the description on Facebook and try again.')
      return render :index
    end

    if result['start_time']
      ffid_date             = DateTime.parse(result['start_time'])
      ffid_date             = ffid_date + 21.hours if ffid_date.strftime('%H:%M:%S') == '00:00:00'
      event.start_time      = ffid_date
    end

    if result['place'] && result['place']['location']
      event.street    = result['place']['location']['street'] if result['place']['location']['street']
      event.zipcode   = result['place']['location']['zip'] if result['place']['location']['zip']
      event.city      = result['place']['location']['city'] if result['place']['location']['city']
      event.country   = result['place']['location']['country'] if result['place']['location']['country']
    end

    event.area = City.find_by(name: event.city).area.domain if City.find_by(name: event.city)

    city_names = City.pluck(:name).join('|')
    if !result['place']['location']['city'].match(/\A(#{city_names})\z/)
      @token.errors.add(:base, "Events for the city #{result['place']['location']['city']} cannot be accepted. All cities for which we support events can be found here: #{root_url(area: nil)}")
      return render :index
    end

    if event.country.blank? && !event.city.blank?
      event.country = 'UK'
    end

    # look out for block words
    for word in BlockWordTitle.all
      next if event.name.blank?

      if event.name.match(/#{word.word}/i)
        @token.errors.add(:base, "The following word in the event name prevents the event from being imported: #{word.word}. Change the event on Facebook and try again.")
        return render :index
      end
    end

    for word in BlockWordDescription.all
      next if event.description.blank?

      if event.description.match(/#{word.word}/i)
        @token.errors.add(:base, "The following word in the description prevents the event from being imported: #{word.word}. Change the event on Facebook and try again.")
        return render :index
      end
    end

    for word in BlockWordLocation.all
      next if event.location.blank?

      if event.location.match(/#{word.word}/i)
        @token.errors.add(:base, "the following word in the location prevents the event from being imported: #{word.word}. Change the event on Facebook and try again.")
        return render :index
      end
    end

    #   # lock out for doubles
    if event.location
      candidate_count = Event.where.not(id: event.id).where(city: event.city).where('start_time > ?', (event.start_time - 30.minutes)).where('start_time < ?', (event.start_time + 30.minutes)).where("location like ?", "%#{event.location}%").count

      if candidate_count > 0
        @candidate = Event.where.not(id: event.id).where(city: event.city).where('start_time > ?', (event.start_time - 30.minutes)).where('start_time < ?', (event.start_time + 30.minutes)).where("location like ?", "%#{event.location}%").first
        @token.errors.add(:base, "There is already an event in this location on the same day.")
        return render :index
      end
    end

    if event.street
      candidate_count = Event.where.not(id: event.id).where(city: event.city).where('start_time > ?', (event.start_time - 30.minutes)).where('start_time < ?', (event.start_time + 30.minutes)).where("street like ?", "%#{event.street}%").count

      if candidate_count > 0
        @candidate = Event.where.not(id: event.id).where(city: event.city).where('start_time > ?', (event.start_time - 30.minutes)).where('start_time < ?', (event.start_time + 30.minutes)).where("street like ?", "%#{event.street}%").first
        @token.errors.add(:base, "There is already an event in this location on the same day.")
        return render :index
      end
    end

    # blocks fetches image from FB
    # TODO: Skip if images match hash sha1 and md5
    if result['cover'] && !result['cover']['source'].blank?
      if Typhoeus.head(result['cover']['source'].gsub("s720x720/", "")).success?
        event.facebook_image_url = result['cover']['source'].gsub("s720x720/", "") # s720x720 is the fb code for small image
      else
        event.facebook_image_url = result['cover']['source']
      end
      Dir.mkdir("#{Rails.root}/tmp/facebook_images") unless File.exist?("#{Rails.root}/tmp/facebook_images")
      response = Typhoeus::Request.get(event.facebook_image_url)
      tmp_path = Rails.root.to_s + "/tmp/facebook_images/#{SecureRandom.uuid()}"
      File.open(tmp_path, 'wb') {|file| file << response.body }
      image = Photo.new()
      image.file = Rack::Test::UploadedFile.new(tmp_path, '/image/jpg')
      image.event = event
    end

    begin
      if event.save
        @event = event
        return render :index
      else
        @token.errors.add(:base, "There was a problem with the event. Check the setting on Facebook and try again later. #{event.errors.full_messages}")
        return render :index
      end
    rescue => e
      @token.errors.add(:base, "Your link is not available on Facebook. Check the link and try again later.")
      return render :index
    end
  end

  private

  def parse_event_token(token)
    result = {}

    session = Capybara::Session.new(:poltergeist)
    session.visit "https://www.facebook.com/events/#{token}"
    # result['code']
    result['code'] = "#{session.status_code}"

    return result if result['code'] != "200" 

    doc = Nokogiri::HTML session.html

	
    if doc.at_css("#u_0_e > div")
      if doc.at_css("#u_0_e > div").text == "You must log in to continue."
        result['privacy'] = "closed"
        return result 
      end
    end

    # result['name']
    if doc.at_css("#seo_h1_tag").text
      result['name'] = doc.at_css("#seo_h1_tag").text
    end

    # result['place']['name']
    result['place'] = {}
    if doc.at_css("#u_0_p")
      result['place']['name'] = doc.at_css("#u_0_p").text
    elsif doc.at_css("a._5xhk")
      result['place']['name'] = doc.at_css("a._5xhk").text
	elsif doc.at_css("#_43q7")
      result['place']['name'] = doc.at_css("#_43q7").text  
    elsif doc.at_css("#_4dpf _phw")
      result['place']['name'] = doc.at_css("#_4dpf _phw").text  
    elsif doc.at_css("h1._5gmx")
      result['place']['name'] = doc.at_css("h1._5gmx").text
    end

	    # result['place']['location']['street']
    result['place']['location'] = {}

    if !doc.css("#u_0_o .fcg").text.empty?
      address = doc.css("#u_0_o .fcg").text
      result['place']['location']['street'] = address.split(",")[0]

      # result['place']['location']['zip']
      result['place']['location']['zip'] = address.split(/(\d{7})/)[1]

      # result['place']['location']['city']
      if address.split(/(\d{7})/)[2]
        result['place']['location']['city'] = address.split(/(\d{7})/)[-1].split(", ")[0].strip
        #result['place']['location']['country'] = address.split(/(\d{7})/)[-1].split(", ")[-1].strip
	   result['place']['location']['country'] = "UK"
      end
    elsif doc.css("div._5xhp.fsm.fwn.fcg")[1]
      address = doc.css("div._5xhp.fsm.fwn.fcg")[1].text
      result['place']['location']['street'] = address.split(",")[0]

      # result['place']['location']['zip']
      result['place']['location']['zip'] = address.split(/(\d{7})/)[1]

      if address.split(/(\d{7})/)[2]
        result['place']['location']['city'] = address.split(/(\d{7})/)[-1].split(", ")[0].strip
		#result['place']['location']['country'] = address.split(/(\d{7})/)[-1].split(", ")[-1].strip
        result['place']['location']['country'] = "UK"
      end
	elsif doc.css("div._5xhp fsm fwn fcg")[1]

      address = doc.css("div._5xhp.fsm.fwn.fcg")[1].text
      result['place']['location']['street'] = address.split(",")[0]

      # result['place']['location']['zip']
      result['place']['location']['zip'] = address.split(/(\d{7})/)[1]

      if address.split(/(\d{7})/)[2]
        result['place']['location']['city'] = address.split(/(\d{7})/)[-1].split(", ")[0].strip
		#result['place']['location']['country'] = address.split(/(\d{7})/)[-1].split(", ")[-1].strip
        result['place']['location']['country'] = "UK"
      end
	end
	
	

    # result['cover']['source']
    result['cover'] = {}
    if doc.at_css("#event_header_primary > div._3kwh > a > div > img")
      result['cover']['source'] = doc.at_css("#event_header_primary > div._3kwh > a > div > img").attr(:src)
    elsif doc.at_css("._egz.img")
      result['cover']['source'] = doc.at_css("._egz.img").attr("src")
    elsif doc.at_css("._2-sx.img")
      result['cover']['source'] = doc.at_css("._2-sx.img").attr("src")
   elsif doc.at_css("._2qgu _7ql _1m6h img")
      result['cover']['source'] = doc.at_css("._2qgu _7ql _1m6h img.img").attr("src")
   elsif doc.at_css("img.scaledImageFitHeight")
      result['cover']['source'] = doc.at_css("img.scaledImageFitHeight").attr("src")
	elsif doc.at_css("img.scaledImageFitWidth")
      result['cover']['source'] = doc.at_css("img.scaledImageFitWidth").attr("src")
   end
   result['cover']['source'].gsub('&amp;','&')


	
	
    # result['description']
    if doc.at_css("._2qgs")
      result['description'] = doc.at_css("._2qgs").text
    elsif doc.at_css("._63ew")
      result['description'] = doc.at_css("._63ew").text
    end

    # result['start_time']
   # result['start_time'] = doc.css("div._publicProdFeedInfo__timeRowTitle._5xhk").attr('content').value.split(" to ").first

    result['start_time'] = doc.css("div._2ycp._5xhk").attr('content').value.split(" to ").first

    session.driver.quit 

	
    return result
  end

  def parse_event_details(token, event_id)
    result = {}
    access_token = token
    event_details = User.get_event_detail(access_token, event_id)

    result['code'] = event_details['code'].present? ? event_details['code'] : 200

    return result if result['code'] != 200
    
    result['privacy'] = event_details['type']

    result['name'] = event_details['name']

    result['place'] = {}

    if event_details['place'].present?
      result['place']['name'] = event_details['place']['name']
      result['place']['location'] = event_details['place']['location']

      if result['place']['location'].present?
        result['place']['location']['city'] = event_details['place']['location']['city']
        result['place']['location']['country'] = event_details['place']['location']['country']
      end

    end

    result['cover'] = {}

    if event_details['cover'].present?
      result['cover']['source'] =  event_details['cover']['source']
    end
    
    result['start_time'] = event_details['start_time']

    result['description'] = event_details['description']


    return result

  end
end
