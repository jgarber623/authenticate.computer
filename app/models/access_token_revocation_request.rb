# IndieAuth IndieWeb Living Standard
# § 7.1 Token Revocation Request
# https://indieauth.spec.indieweb.org/#token-revocation-request
class AccessTokenRevocationRequest
  include ActiveModel::Model

  attr_accessor :action, :token

  validates :action, presence: true, inclusion: { in: ['revoke'] }
  validates :token, presence: true
end
