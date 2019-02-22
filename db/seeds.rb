if !(area = Area.find_by(:name => 'Berlin'))
  area = Area.new
  area.name = 'Berlin'
  area.domain = 'berlin'
  area.save
end

if !(city = City.find_by(:name => 'Berlin'))
  city = City.new
  city.name = 'Berlin'
  city.area = area
  city.save
end

if !(area = Area.find_by(:name => 'Hamburg'))
  area = Area.new
  area.name = 'Hamburg'
  area.domain = 'hamburg'
  area.save
end

if !(city = City.find_by(:name => 'Hamburg'))
  city = City.new
  city.name = 'Hamburg'
  city.area = area
  city.save
end

if !(area = Area.find_by(:name => 'Frankfurt am Main'))
  area = Area.new
  area.name = 'Frankfurt am Main'
  area.domain = 'frankfurt-am-main-und-umgebung'
  area.save
end

if !(city = City.find_by(:name => 'Frankfurt'))
  city = City.new
  city.name = 'Frankfurt am Main'
  city.area = area
  city.save
end

e = Event.new
e.uuid = SecureRandom.uuid
e.eid = Random.rand(99999999)
e.name = "Yeah - one day old"
e.start_time = Time.zone.now - 1.day
e.location = "Travolta"
e.street = "Brönnerstraße 17"
e.zipcode = "60313"
e.city = 'Frankfurt am Main'
e.area = area.domain
e.country = "Germany"
e.description = "Some nice party https://www.youtube.com/watch?v=Bi8MtzG6Lfw"
e.facebook_image_url = "http://url.com"
p = e.build_photo
p.file = Rack::Test::UploadedFile.new(Rails.root.to_s + '/test-flyer/yeah.jpg', '/image/jpg')
e.save

e = Event.new
e.uuid = SecureRandom.uuid
e.eid = Random.rand(99999999)
e.name = "Theater"
e.start_time = Time.zone.now + 1.day
e.location = "Travolta"
e.street = "Brönnerstraße 17"
e.zipcode = "60313"
e.city = 'Frankfurt am Main'
e.area = area.domain
e.country = "Germany"
e.description = "Some nice party https://www.youtube.com/watch?v=Bi8MtzG6Lfw"
e.facebook_image_url = "http://url.com"
p = e.build_photo
p.file = Rack::Test::UploadedFile.new(Rails.root.to_s + '/test-flyer/theater.jpg', '/image/jpg')
e.save

e = Event.new
e.uuid = SecureRandom.uuid
e.eid = Random.rand(99999999)
e.name = "Brilliant Soul"
e.start_time = Time.zone.now
e.location = "Travolta"
e.street = "Brönnerstraße 17"
e.zipcode = "60313"
e.city = 'Frankfurt am Main'
e.area = area.domain
e.country = "Germany"
e.description = "Some nice party"
e.facebook_image_url = "http://url.com"
p = e.build_photo
p.file = Rack::Test::UploadedFile.new(Rails.root.to_s + '/test-flyer/brilliantsoul.jpg', '/image/jpg')
e.save

e = Event.new
e.uuid = SecureRandom.uuid
e.eid = Random.rand(99999999)
e.name = "Yeah - today"
e.start_time = Time.zone.now
e.location = "Travolta"
e.street = "Brönnerstraße 17"
e.zipcode = "60313"
e.city = 'Frankfurt am Main'
e.area = area.domain
e.country = "Germany"
e.description = "Some nice party"
e.facebook_image_url = "http://url.com"
p = e.build_photo
p.file = Rack::Test::UploadedFile.new(Rails.root.to_s + '/test-flyer/yeah.jpg', '/image/jpg')
e.save

e = Event.new
e.uuid = SecureRandom.uuid
e.eid = Random.rand(99999999)
e.name = "8 Jahre Tanzhaus West mit Efdemin, Aka Aka, uva"
e.start_time = Time.zone.now
e.location = "Tanzhaus West, Dora Brilliant & Landungsbrücken"
e.street = "Gutleutstrasse 294"
e.zipcode = "60327"
e.city = 'Frankfurt am Main'
e.area = area.domain
e.country = "Germany"
e.description = "Efdemin [dial, naif]
              Aka Aka & Thalstroem LIVE! [burlesque musique]
              Peter Schumann [bar 25, tanzhaus west]
              Basti Pieper [resopal, herz ist trumpf]
              Bo Irion [tanzhaus west]
              Steffen Nehrig [two birds]
              Benjamin Stager [funky people]
              Hörsturz [hbf musik]
              Benjamin Tritschler [stay]
              Grille & Steve Simon [toxic family]
              Florian König [move]
              DJ Slowhand [tage dieb]
              Ian May [nullkommanix]
              http://www.tanzhaus-west.de/
              Tanzhaus West, Dora Brilliant & Landungsbrücken | 23:00h | Techno, House')"
e.facebook_image_url = "http://url.com"
p = e.build_photo
p.file = Rack::Test::UploadedFile.new(Rails.root.to_s + '/test-flyer/tanzhauswest.jpg', '/image/jpg')
e.save

if !(area = Area.find_by(:name => 'Darmstadt'))
  area = Area.new
  area.name = 'Darmstadt'
  area.domain = 'darmstadt'
  area.save
end

if !(city = City.find_by(:name => 'Darmstadt'))
  city = City.new
  city.name = 'Darmstadt'
  city.area = area
  city.save
end

e = Event.new
e.uuid = SecureRandom.uuid
e.eid = Random.rand(99999999)
e.name = "NEON LOVE AFFAIR x SLAP IN THE BASS"
e.start_time = Time.zone.now + 1.day
e.location = "Hafen 2"
e.street = "Hafen 2a"
e.zipcode = "63067"
e.city = 'Darmstadt'
e.area = area.domain
e.country = "Germany"
e.description = "Freitag, 02.12.11 | 23:00 Uhr

Eintritt: 8€ | 6€ Friendlist

SLAP IN THE BASS (No Brainer | Southern Fried | Top Billin | Budapest)
STEREOHAUNTS (NLA Residents | We Are Us)
STEFFEN SENNERT (NLA Resident | Rave! Rave!)
___________________________________________________________

Nach Erol Alkan wird es mal wieder Zeit ein absolutes Highlight im Hafen 2 begrüßen zu dürfen…

Diverse Releases auf No Brainer Records, Top Billin und Southern Fried Records, den derzeit angesagtesten Labels überhaupt. Platz 1 in den Beatport Charts mit ihrem Crookers Remix. Support von DJ Größen wie Brodinski, Steve Aoki, Diplo, Fatboy Silm und Zombie Nation. Und das alles nach nur einem Jahr im Business. SLAP IN THE BASS legen einen absoluten Traumstart hin. Kein Wunder denn ihr unverkennbarer Mix aus UK Funky, Dutch House und Ghetto Techno ist zweifellos der heisseste Scheiss!
___________________________________________________________

FRIENDSLIST auf http://www.neonloveaffair.de/
___________________________________________________________

Links:

www.neonloveaffair.de
www.hafen2.de"
e.facebook_image_url = "http://url.com"
p = e.build_photo
p.file = Rack::Test::UploadedFile.new(Rails.root.to_s + '/test-flyer/slap.jpg', '/image/jpg')
e.save

area = Area.find_by(:name => 'Berlin')

e = Event.new
e.uuid = SecureRandom.uuid
e.eid = Random.rand(99999999)
e.name = "Theater"
e.start_time = Time.zone.now
e.location = "Travolta"
e.street = "Brönnerstraße 17"
e.zipcode = "60313"
e.city = 'Berlin'
e.area = area.domain
e.country = "Germany"
e.description = "Some nice party https://www.youtube.com/watch?v=Bi8MtzG6Lfw"
e.facebook_image_url = "http://url.com"
p = e.build_photo
p.file = Rack::Test::UploadedFile.new(Rails.root.to_s + '/test-flyer/theater.jpg', '/image/jpg')
e.save
