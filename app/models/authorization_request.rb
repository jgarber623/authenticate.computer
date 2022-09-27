# IndieAuth IndieWeb Living Standard
# § 5.2 Authorization Request
# https://indieauth.spec.indieweb.org/#authorization-request
class AuthorizationRequest
  include ActiveModel::Model

  attr_accessor :response_type, :client_id, :redirect_uri, :state, :code_challenge, :code_challenge_method, :scope, :me

  # OAuth 2.0 Simplified
  # § 17.1 Authorization Request
  # https://www.oauth.com/oauth2-servers/pkce/authorization-request/
  validates :response_type, presence: true, inclusion: {
                                              in: ['code'],
                                              message: 'must be “code”'
                                            }
  validates :client_id, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :redirect_uri, presence: true,
                           format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) },
                           inclusion: {
                             in: :permitted_redirect_uris,
                             message: ->(object, data) { redirect_uri_inclusion_error_message(object, data) }
                           }
  validates :state, presence: true, length: { minimum: 16 }
  validates :code_challenge, presence: true
  validates :code_challenge_method, presence: true, inclusion: {
                                                      in: %w[plain S256],
                                                      message: 'must be “plain” or “S256”'
                                                    }
  validates :me, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, if: -> { me.present? }

  def permitted_redirect_uris
    return [] if (errors.where(:redirect_uri) + errors.where(:client_id)).any?
    return Array(redirect_uri) if Addressable::URI.parse(redirect_uri).host == Addressable::URI.parse(client_id).host

    IndieWeb::Endpoints.get(client_id)[:redirect_uri].to_a
  rescue IndieWeb::Endpoints::Error => e
    # Log exception somewhere
    # Do something
  end

  def scopes
    scope.to_s.split(/(?:\s|%20|\+|,)+/).map(&:downcase).uniq
  end

  class << self
    private

    def redirect_uri_inclusion_error_message(_object, data)
      "“#{data[:value]}” is not a registered redirect_uri"
    end
  end
end
