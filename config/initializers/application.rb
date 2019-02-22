Rails.application.configure do
  config.application_url = 'www.wasgehtheuteab.de'

  if Rails.env.development?
    config.application_url = 'localhost' # APP_URL
  elsif Rails.env.test?
    config.application_url = 'localhost'
  end
end

Capybara.javascript_driver = :poltergeist
