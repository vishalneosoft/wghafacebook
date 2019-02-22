class ApplicationController < ActionController::Base
  before_action :set_area, except: [ :route_not_found, :facebook ]
  before_action :set_subdomain

  rescue_from Exception, :with => :render_500 if Rails.env.production?
  rescue_from ActiveRecord::RecordNotFound, :with => :resource_not_found
  rescue_from ActionController::UnknownFormat, :with => :resource_not_found

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => '4464f1ff0ebe4deff0e238fab7e32e55'

  def route_not_found
    return redirect_to root_url(area: nil), status: 301
  end

  private
  def resource_not_found(exception)
    return if !set_area
    return if !set_subdomain

    return render template: "error_handling/not_found", status: 404, formats: 'html'
  end

  def render_500(exception)
    return if !set_area
    return if !set_subdomain

    ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
    return render template: "error_handling/error", status: 500, formats: 'html'
  end

  def default_url_options(options={})
    current_area = @current_area.domain if @current_area
    { area: current_area, host: new_request_host }
  end

  def new_request_host
    if Rails.env.production?
      "www.wasgehtheuteab.de"
    else
      "www.local-wgha.de:#{request.port}"
    end
  end

  def set_subdomain
    case request.subdomain
    when 'www'
      return true
    else
      redirect_to subdomain: 'www'
      return false
    end
  end

  def set_area
    @current_area = Area.find_by(domain: params[:area])
    if !@current_area
      redirect_to root_url(area: nil), status: 301
      return false
    end
    return true
  end

  def set_request_host
    @new_request_host = new_request_host
  end

  def cache_control
    expires_in 5.minutes, public: true
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    URI.parse(request.referer).path if request.referer
  end
end
