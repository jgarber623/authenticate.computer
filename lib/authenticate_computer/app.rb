module AuthenticateComputer
  class App < Sinatra::Base
    configure do
      set :root, File.dirname(File.expand_path('..', __dir__))

      set :raise_errors, true
      set :raise_sinatra_param_exceptions, true
      set :show_exceptions, :after_handler
    end

    register Sinatra::AssetPipeline
    register Sinatra::Param

    # get '/auth' do
    #   param :me,            required: true, format: uri_regexp, transform: ->(me) { Addressable::URI.parse(me).normalize.to_s }
    #   param :client_id,     required: true, format: uri_regexp
    #   param :redirect_uri,  required: true, format: uri_regexp, in: IndieWeb::Endpoints.get(params[:client_id]).redirect_uri.to_a
    #   param :state,         required: true
    #   param :scope,         default: ''
    #   param :response_type, default: 'id', in: %w[code id]
    #
    #   # fetch the me URL for user information
    #   # fetch the client_id URL for app information
    #   # set the session
    #   # display authentication options
    #
    #   erb :auth
    # end

    # post '/auth' do
    #   param :code,         required: true
    #   param :client_id,    required: true, format: uri_regexp, match: '' # session's client_id
    #   param :redirect_uri, required: true, format: uri_regexp, match: '' # session's redirect_uri
    # end

    error 404 do
      cache_control :public

      erb :'404'
    end

    # error Sinatra::Param::InvalidParameterError do
    #   erb :'400', locals: { error: env['sinatra.error'].message }
    # end

    private

    def uri_regexp
      @uri_regexp ||= URI.regexp(%w[http https])
    end
  end
end
