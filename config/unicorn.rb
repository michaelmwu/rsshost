if ENV['RAILS_ENV'] == "development"
  timeout 50
  preload_app false
else
  timeout 15         # kills requests that take more than 15 seconds
  preload_app true
end

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3) # amount of unicorn workers to spin up

port = ENV["PORT"].to_i
listen port, :tcp_nopush => false

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  if defined?(ActiveRecord::Base)
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    config['pool'] = ENV['DB_POOL'] || 2
    ActiveRecord::Base.establish_connection(config)
  end
end
