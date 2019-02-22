source 'https://rubygems.org'

gem 'rails', '5.2.0'
gem 'bootsnap', require: false

gem 'json'
gem 'mini_magick'
gem 'addressable', :require => 'addressable/uri'
gem 'mysql2'
gem 'yajl-ruby'
gem 'will_paginate', git: 'https://github.com/jonatack/will_paginate.git'
gem "auto_html", :git => 'https://github.com/bigcurl/auto_html.git', branch: 'feature/fix-wrong-url'
gem 'redcarpet'
gem 'icalendar', :require => 'icalendar'

# against ActionController::BadRequest
gem 'utf8-cleaner'

gem "typhoeus"
gem 'uglifier'

gem "poltergeist", :require => 'capybara/poltergeist'
gem 'omniauth-facebook'
gem "koala", "~> 1.10.0rc"
gem 'devise'
gem 'thin'


group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'annotate'
  gem 'byebug'
  gem 'rb-readline'
  gem 'web-console'
  gem 'spring'
  gem 'puma'
  gem 'pry'
  gem 'capybara'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
end

group :production do
  gem "lograge"
  gem 'therubyracer'
  gem 'yui-compressor'
  gem 'exception_notification'
  gem 'execjs'
end
