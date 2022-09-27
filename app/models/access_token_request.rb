# IndieAuth IndieWeb Living Standard
# 5.3 Redeeming the Authorization Code
# https://indieauth.spec.indieweb.org/#x5-3-redeeming-the-authorization-code
class AccessTokenRequest
  include ActiveModel::Model

  attr_accessor :grant_type, :code, :client_id, :redirect_uri, :code_verifier

  validates :grant_type, presence: true, inclusion: { in: ['authorization_code'] }
  validates :code, presence: true
  validates :client_id, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :redirect_uri, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :code_verifier, presence: true
end
