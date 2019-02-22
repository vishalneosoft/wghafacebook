class IdToken
  include ActiveModel::Validations
  attr_accessor :token

  validates :token,
  presence: true,
  length: { maximum: 100 },
  numericality: { only_integer: true, allow_blank: true }

  def initialize(params)
    self.token = params[:token][:token].match(/\d+/).to_s
  end
end
