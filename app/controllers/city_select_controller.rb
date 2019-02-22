class CitySelectController < ApplicationController
  force_ssl if Rails.env.production?
  skip_before_action :set_area

  def index
    expires_in 1.hours, public: true
    @areas = Area.order('name')
    fresh_when(etag: @areas.pluck(:updated_at), public: true)
  end
end
