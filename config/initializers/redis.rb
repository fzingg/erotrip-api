module EroRedis
  def self.connect
    if Rails.env.test?
      $redis = Redis.new()
    else
      $redis = Redis::Namespace.new(ENV['REDIS_CHANNEL_PREFIX'], redis: Redis.new(driver: :hiredis, host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'].to_i))
    end
  end
end

EroRedis.connect