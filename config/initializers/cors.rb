# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins '127.0.0.1:3000'
    # origins 'localhost:3000'
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :patch, :put]
  end
end
