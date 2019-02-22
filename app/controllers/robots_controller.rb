class RobotsController < ApplicationController
  force_ssl if Rails.env.production?
  skip_before_action :set_area
  before_action :cache_control
  layout nil

  def index
    case request.subdomain
    when 'www'
      robot_file = ""

      for area in Area.all
        robot_file << "Sitemap: #{sitemap_city_index_url(area: area.domain)}\n"
      end

      robot_file << "\nUser-agent: *\n"
      robot_file << "Disallow: /photos/*\n"
      robot_file << "Disallow: /*/impressum\n"
      robot_file << "Disallow: /*/agb\n"
      robot_file << "Disallow: /*/datenschutz\n"
      robot_file << "Allow: /\n"
      robot_file << "Host: https://www.wasgehtheuteab.de\n"
      robot_file << "\nUser-agent: ia_archiver\n"
      robot_file << "Disallow: /\n"
    else
      robot_file = <<CONTENT
User-Agent: *
Disallow: /
CONTENT
    end

    render plain: robot_file
  end
end
