class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook]

  def self.login_from_facebook(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
    end
  end

  def self.get_event_detail(token, event_id)
    access_token = token
    facebook = Koala::Facebook::API.new(access_token)
    begin
      facebook.get_object("#{event_id}?fields=id,name,place,start_time,type,attending_count,cover,description")
    rescue Exception => e
      facebook = { "code" => 400 }
    end
  end
end
