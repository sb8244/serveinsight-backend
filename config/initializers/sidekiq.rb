if Rails.env.test?
  sidekiq_redis = ConnectionPool.new { MockRedis.new }
else
  sidekiq_redis = { namespace: "serveinsight" }
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis
end

Sidekiq.configure_server do |config|
  config.redis = sidekiq_redis
  # database_url = ENV['DATABASE_URL']
  # if database_url
  #   ENV['DATABASE_URL'] = "#{database_url}?pool=40"
  #   ActiveRecord::Base.establish_connection
  # end
end
