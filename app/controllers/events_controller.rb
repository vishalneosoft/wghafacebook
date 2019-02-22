class EventsController < ApplicationController
  force_ssl if Rails.env.production?
  before_action :cache_control

  def index
    if stale?(etag: Event.in_area(@current_area).today.pluck(:updated_at), public: true)
      @time = Time.zone.now - 8.hours
      @events = Event.backwards.includes_photos.in_area(@current_area).today
      respond_to do |format|
        format.html
        format.rss { render :layout => false }
      end
    end
  end

  def show
    if stale?(etag: Event.where(uuid: params[:uuid]).pluck(:updated_at).first, last_modified: Event.where(uuid: params[:uuid]).pluck(:updated_at).first, public: true)
      @event = Event.includes_photos.where(uuid: params[:uuid]).first

      if !@event || @event.photo.nil?
        if !@current_area
          return redirect_to root_url(area: nil), status: 301
        end

        return render template: "error_handling/not_found", status: 404, formats: 'html'
      end

      @events_preview = Event.includes_photos.where(id: Event.where.not(id: @event.id).in_area(@current_area).on_same_day_as(@event).pluck(:id).sample(6))

      respond_to do |format|
        format.html
        format.amp { render :layout => false }
        format.ics { render plain: @event.to_ical(event_url(uuid: @event.uuid)) }
      end
    end
  end
end
