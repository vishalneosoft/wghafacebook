# == Schema Information
#
# Table name: events
#
#  id                  :integer          not null, primary key
#  photo_id            :integer
#  uuid                :binary(64)
#  eid                 :string(255)
#  name                :string(255)
#  location            :string(255)
#  street              :string(255)
#  zipcode             :string(255)
#  city                :string(255)
#  area                :string(255)
#  country             :string(255)
#  website             :string(255)
#  start_time          :datetime
#  email_from_uploader :string(255)
#  description         :text(65535)
#  description_html    :text(65535)
#  ticket_url          :string(255)
#  facebook_image_url  :string(255)
#  status              :string(255)
#  updated_at          :datetime         not null
#  created_at          :datetime         not null
#  description_amp     :text(65535)
#

class Event < ApplicationRecord
  include AutoHtml

  belongs_to :photo, :dependent => :destroy

  validates_presence_of :name, :location, :city, :country, :facebook_image_url
  validates_length_of   :name, :maximum => 500, :allow_blank => true
  validates :city, inclusion: { in: City.pluck(:name)}
  validates_uniqueness_of :eid, :case_sensitive => false, :allow_blank =>true
  validates_uniqueness_of :uuid, :case_sensitive => false, :allow_blank =>true

  scope :backwards,          -> { order('"index_events_on_start_time" desc') }
  scope :forwards,           -> { order('"index_events_on_start_time" asc') }
  scope :random,             -> { order("RAND()") }
  scope :includes_photos,    -> { includes(:photo) }
  scope :in_area,            ->(area) { where(area: area.domain) }
  scope :upcoming,           -> { where('start_time > ?', (Time.zone.now - 8.hours).end_of_day + 8.hours) }
  scope :starting_from_today,-> { where('start_time > ?', (Time.zone.now - 8.hours).beginning_of_day + 8.hours) }
  scope :past,               -> { where('start_time < ?', (Time.zone.now - 8.hours).beginning_of_day + 8.hours) }
  scope :on_same_day_as,     ->(event) { where(start_time: ((event.start_time - 8.hours).beginning_of_day + 8.hours)..((event.start_time - 8.hours).end_of_day + 8.hours)) }
  scope :on_day,             ->(time) { where(start_time: ((time - 8.hours).beginning_of_day + 8.hours)..((time - 8.hours).end_of_day + 8.hours)) }
  scope :in_the_next_month,  -> {where(start_time: (((Time.zone.now + 1.days) - 8.hours).beginning_of_day + 8.hours)..(((Time.zone.now - 8.hours) ).end_of_day + 8.hours + 1.months - 2.days))}
  scope :today,              -> { where(start_time: ((Time.zone.now - 8.hours).beginning_of_day + 8.hours)..((Time.zone.now - 8.hours).end_of_day + 8.hours)) }

  before_save :trigger_auto_html

  def to_param
    "#{uuid}"
  end

  def website=(url)
    begin
      url = Addressable::URI.heuristic_parse(url)
    rescue
      self[:website] = ""
      errors.add(:base, "Webseite hat kein gültiges Format.")
    end
    self[:website] = url.to_s
  end

  def to_ical(event_url)
    calendar = Icalendar::Calendar.new
    calendar.prodid = 'www.wasgehtheuteab.de'
    event = Icalendar::Event.new
    event.dtstart = self.start_time.strftime("%Y%m%dT%H%M%S")
    event.dtend = (self.start_time + 3.hours).strftime("%Y%m%dT%H%M%S")
    event.summary = self.name
    event.description = "Partys & Konzerte - Ausgehen im Nachtleben von #{self.city}. Wir zeigen dir auf www.wasgehtheuteab.de wohin man abends ausgehen kann."
    event.location = "#{self.location}, #{self.street}, #{self.zipcode} #{self.city}"
    event.ip_class = "PUBLIC"
    event.created = self.created_at
    event.last_modified = self.updated_at
    event.uid = self.uuid
    event.url = event_url
    calendar.add_event(event)
    calendar.to_ical
  end

  private
  def trigger_auto_html
    begin
      self[:description_html] = auto_html(self[:description]) do
        # html_escape this should be also set but makes problems with umlauts
        sanitize
        youtube(width: 320, height: 200)
        vimeo(width: 320, height: 200)
        link(short_link_name: true, rel: "nofollow")
        redcarpet
      end
      self[:description_amp] = auto_html(self[:description]) do
        # html_escape this should be also set but makes problems with umlauts
        sanitize
        amp_youtube(width: 320, height: 200)
        amp_vimeo(width: 320, height: 200)
        link(short_link_name: true, rel: "nofollow")
        redcarpet
      end
    rescue
      self[:description_amp] = self[:description_html] = auto_html(self[:description]) do
        # html_escape this should be also set but makes problems with umlauts
        sanitize
        redcarpet
      end
    end
  end
end
