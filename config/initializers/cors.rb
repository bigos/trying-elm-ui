# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  if Rails.env.development?
    Rails.logger.info "using development cors"
    allow do
      # origins '127.0.0.1:3000'
      # origins 'localhost:3000'
      origins '*'
      resource '*', headers: :any, methods: [:get, :post, :patch, :put]
    end
  else
    Rails.logger.info "using production cors"
    domain = 'https://localhost:5000'
    allow do
      origins domain
      resource domain, headers: :any, methods: [:get, :post, :patch, :put]
    end
  end
end
