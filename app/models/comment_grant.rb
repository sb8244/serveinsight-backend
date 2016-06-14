class CommentGrant
  JWT_SECRET = Rails.application.secrets.jwt_secret
  JWT_ALGORITHM = Rails.application.secrets.jwt_algorithm

  attr_reader :commentable_id, :commentable_type

  def initialize(token)
    @payload = JWT.decode(token, JWT_SECRET, JWT_ALGORITHM).first.with_indifferent_access
    @commentable_id = @payload[:commentable_id]
    @commentable_type = @payload[:commentable_type]
  rescue JWT::DecodeError
    nil
  end

  def valid?
    commentable_id.presence && commentable_type.presence && Time.now < Time.at(@payload[:exp].to_i)
  end

  def self.encode(obj, duration: 4.hours)
    payload = { commentable_id: obj.id, commentable_type: obj.class.name, exp: (duration.from_now).to_i }
    JWT.encode(payload, JWT_SECRET, JWT_ALGORITHM)
  end
end
