# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  domain     :string(50)       default(""), not null
#  name       :string(50)       default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :integer
#  area_id    :integer          not null
#

class City < ApplicationRecord
  belongs_to :area
end
