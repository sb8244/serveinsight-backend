if Rails.env.test?
  $redis = MockRedis.new
else
  if ENV["REDIS_PROVIDER"]
    uri = URI.parse(ENV.fetch(ENV["REDIS_PROVIDER"]))
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    $redis = Redis.new
  end
end
