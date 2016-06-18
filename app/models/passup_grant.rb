class PassupGrant
  JWT_SECRET = Rails.application.secrets.jwt_secret
  JWT_ALGORITHM = Rails.application.secrets.jwt_algorithm

  attr_reader :passupable_id, :passupable_type

  def initialize(token)
    @payload = JWT.decode(token, JWT_SECRET, JWT_ALGORITHM).first.with_indifferent_access
    @passupable_id = @payload[:passupable_id]
    @passupable_type = @payload[:passupable_type]
  rescue JWT::DecodeError
    nil
  end

  def valid?
    passupable_id.presence && passupable_type.presence && Time.now < Time.at(@payload[:exp].to_i)
  end

  def self.encode(obj, duration: 12.hours)
    payload = { passupable_id: obj.id, passupable_type: obj.class.name, exp: (duration.from_now).to_i }
    JWT.encode(payload, JWT_SECRET, JWT_ALGORITHM)
  end
end
