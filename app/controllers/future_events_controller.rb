class FutureEventsController < ApplicationController
  force_ssl if Rails.env.production?
  before_action :cache_control

  def index
    if stale?(etag: Event.in_area(@current_area).in_the_next_month.pluck(:updated_at), public: true)
      @events = Event.in_area(@current_area).in_the_next_month.order(:start_time).group("DATE(start_time)").count
    end
  end

  def show
    begin
      @time = Time.zone.parse(params[:date]) + 8.hours
    rescue
      return redirect_to future_events_url
    end

    if stale?(etag: Event.in_area(@current_area).on_day(@time).pluck(:updated_at), public: true)
      @events = Event.backwards.in_area(@current_area).on_day(@time)
    end
  end
end
