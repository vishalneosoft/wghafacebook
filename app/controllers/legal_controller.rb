class LegalController < ApplicationController
  force_ssl if Rails.env.production?
  before_action :cache_control

  def index
    respond_to do |format|
      format.html { render(:about) }
    end
  end

  def imprint
    respond_to :html
  end

  def privacy
    respond_to :html
  end

  def tos
    respond_to :html
  end

  def about
    respond_to :html
  end
end
