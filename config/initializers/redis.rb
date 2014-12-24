if redis_url = ENV["REDIS_URL"] || ENV["REDISTOGO_URL"] || ENV["REDISCLOUD_URL"]
  uri = URI.parse(redis_url)
  $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)
else
  $redis = Redis.new(:thread_safe => true)
end
