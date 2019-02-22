Rails.application.routes.draw do
  #devise facebook login
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get '/favicon.bmp' => redirect(path: "/assets/favicon.ico", host: Wasgeht::Application.config.application_url)
  get '/apple-touch-icon-*png' => redirect(path: '/assets/apple-touch-icon.png', host: Wasgeht::Application.config.application_url)

  root  :to => "city_select#index"

  get '/robots.txt'  => 'robots#index', defaults: { format: :text }

  #devise facebook logout
  devise_scope :user do
    get '/users/sign_out', to: 'devise/sessions#destroy', as: :sign_out
  end

  scope '/:area' do
    get '/' => "events#index", :as => :events
    get '/' => "events#index", :as => :area
    get 'e/:uuid' => "events#show", constraints: { uuid: /[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}/ }, :as => :event
    get 'a/:uuid' => "events#show", constraints: { uuid: /[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}/ },   defaults: { format: :amp }, :as => :event_amp
    get 'i/:uuid' => "events#show", constraints: { uuid: /[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}/ },   defaults: { format: :ics }, :as => :event_ics
    get '/was-geht-demnaechst-ab' => "future_events#index", :as => :future_events
    get '/d/was-geht-am-:date-ab' => "future_events#show", :as => :future_event, constraints: { date: /\d(\d)?\.\d(\d)?\.\d\d\d\d/ }
    get '/ueber-uns'    => 'legal#about', :as => :about
    get '/impressum'    => 'legal#imprint', :as => :imprint
    get '/datenschutz'  => 'legal#privacy', :as => :privacy
    get '/agb'          => 'legal#tos', :as => :tos

    scope module: 'sitemap' do
      get '/sitemap.xml'    => 'city#index',  defaults: { format: :xml }, as: :sitemap_city_index
      get '/sitemap/root.xml'    => 'city#root',   defaults: { format: :xml }, as: :sitemap_city_root
      get '/sitemap/:page.xml'    => 'city#show',   defaults: { format: :xml }, constraints: { :page => /\d*+/ }, as: :sitemap_city_show
    end

    scope '/kontakt' do
      get  '/' => 'legal#imprint', :as => :contact_index
    end

    scope '/flyer-hochladen' do
      get  '/' => "upload#index", :as => :upload_index
      post '/' => "upload#create"
      post '/e' => "upload#create_event", as: :upload_index_event
      get  '/finish' => "upload#finish", :as => :finish_upload_index
    end
  end

  get '*unmatched_route', to: 'application#route_not_found'
end
