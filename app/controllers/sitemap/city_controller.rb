# More info: http://www.sitemaps.org/de/protocol.html
class Sitemap::CityController < ApplicationController
  before_action :set_request_host
  force_ssl if Rails.env.production?
  layout nil

  def index
    if stale?(etag: Event.in_area(@current_area).maximum(:updated_at), last_modified: Event.in_area(@current_area).maximum(:updated_at), public: true)
      @events_count = Event.in_area(@current_area).count
      @array = {}
      (@events_count.to_f / 1000).ceil.times do |count|
       count = count + 1
       ids = Event.in_area(@current_area).order('events.created_at ASC').page(count).per_page(1000).pluck(:id)
       @array[count] = Event.in_area(@current_area).where(id: ids).maximum(:updated_at)
     end
    end
  end

  def show
    event_ids = Event.in_area(@current_area).order('events.created_at ASC').page(params[:page]).per_page(1000).pluck(:id)
    if stale?(etag: Event.where(id: event_ids).maximum(:updated_at), last_modified: Event.where(id: event_ids).maximum(:updated_at), public: true)
      @flyers = Event.where(id: event_ids).pluck(:uuid, :area, :updated_at)
    end
  end

  def root
    if stale?(etag: Event.in_area(@current_area).in_the_next_month.maximum(:updated_at), last_modified: Event.in_area(@current_area).in_the_next_month.maximum(:updated_at), public: true)
      @array = {}
      ((((Time.zone.now + 1.days) - 8.hours).beginning_of_day + 8.hours).to_date..(((Time.zone.now - 8.hours).end_of_day + 8.hours + 1.months - 2.days)).to_date).each do |current_date|
        @array[current_date.to_date] = Event.on_day(current_date).maximum(:updated_at)
      end
    end
  end
end
