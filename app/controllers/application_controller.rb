class ApplicationController < Sinatra::Base
  register Sinatra::Partial

  configure :production do
    use Rack::SslEnforcer, redirect_html: false
    use Rack::HostRedirect, %w[www.authenticate.computer] => 'authenticate.computer'
    use Rack::Deflater
  end

  configure do
    set :root, File.dirname(File.expand_path('..', __dir__))
    set :views, 'app/views'

    set :datastore, Redis.new
    set :partial_template_engine, :erb
    set :partial_underscores, true
    set :raise_sinatra_param_exceptions, true

    set :assets_css_compressor, :sass
    set :assets_paths, %w[app/assets/images app/assets/stylesheets]
    set :assets_precompile, %w[*.png application.css]

    use Rack::Session::Cookie, expire_after: 60, key: ENV['COOKIE_NAME'], secret: ENV['COOKIE_SECRET']

    use Rack::Protection, use: [:cookie_tossing]
    use Rack::Protection::AuthenticityToken, allow_if: ->(env) { env['REQUEST_METHOD'] == 'POST' && ['/auth', '/token'].include?(env['PATH_INFO']) }
    use Rack::Protection::ContentSecurityPolicy, default_src: "'self'", style_src: "'self' https://fonts.googleapis.com", font_src: "'self' https://fonts.gstatic.com", frame_ancestors: "'none'"
    use Rack::Protection::StrictTransport, max_age: 31_536_000, include_subdomains: true, preload: true

    use OmniAuth::Builder do
      provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: 'read:user'
    end

    OmniAuth.config.allowed_request_methods = [:post]
    OmniAuth.config.on_failure = ->(env) { OmniAuth::FailureEndpoint.new(env).redirect_to_failure }
  end

  register Sinatra::AssetPipeline
  register Sinatra::Param
  register Sinatra::RespondWith

  helpers ApplicationHelper

  after do
    halt [406, { 'Content-Type' => 'text/plain' }, 'The requested format is not supported'] if status == 500 && body.include?('Unknown template engine')
  end

  error 400 do
    render_alert error: 'invalid_request', error_title: '400 Bad Request', error_description: "#{request.env['sinatra.error'].message}. Please try again."
  end

  error 404 do
    render_alert error: 'file_not_found', error_title: '404 File Not Found', error_description: %(The requested URL could not be found. Head on <a href="/" rel="home">back to the homepage</a>.)
  end

  error 440 do
    render_alert error: 'session_timeout', error_title: '440 Session Timeout', error_description: "#{request.env['sinatra.error'].message}. Please try again."
  end

  error 500 do
    render_alert error: 'server_error', error_title: '500 Internal Server Error', error_description: "#{request.env['sinatra.error'].message}. Please try again later."
  end
end
