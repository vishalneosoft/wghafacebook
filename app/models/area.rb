# == Schema Information
#
# Table name: areas
#
#  id                     :integer          not null, primary key
#  country_id             :integer
#  free_day_id            :integer
#  name                   :string(255)
#  domain                 :string(255)
#  adsense_ad_slot_header :string(255)
#  adsense_ad_slot_footer :string(255)
#  adsense_ad_slot_show   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Area < ApplicationRecord
end
