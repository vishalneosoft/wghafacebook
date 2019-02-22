ActionMailer::Base.smtp_settings = {
  address: "smtp.server.com",
  port: 587,
  authentication: :plain,
  domain: 'wasgehtheuteab.de',
  user_name: "USERNAME",
  password:'*******',
  enable_starttls_auto: true
}
