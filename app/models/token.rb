# https://github.com/sahat/satellizer/blob/master/examples/server/ruby/app/models/token.rb
class Token
  JWT_SECRET = Rails.application.secrets.jwt_secret
  JWT_ALGORITHM = Rails.application.secrets.jwt_algorithm

  attr_reader :user_id, :payload

  def initialize(token)
    @payload = JWT.decode(token, JWT_SECRET, JWT_ALGORITHM).first.with_indifferent_access
    @user_id = @payload[:user_id]
  rescue JWT::DecodeError
    nil
  end

  def valid?
    user_id.presence && Time.now < Time.at(@payload[:exp].to_i)
  end

  def self.encode(user_id)
    payload = { user_id: user_id, exp: (30.days.from_now).to_i }
    JWT.encode(payload, JWT_SECRET, JWT_ALGORITHM)
  end
end
