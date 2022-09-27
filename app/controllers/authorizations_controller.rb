class AuthorizationsController < ApplicationController
  def new
    if authorization_request.valid?
      client_metadata if authorization_request.me.present?

      render status: :ok
    else
      render status: :bad_request
    end
  end

  def show
  end

  private

  def authorization_request
    @authorization_request ||= AuthorizationRequest.new(authorization_request_params)
  end

  def authorization_request_params
    params.permit(
      :client_id,
      :code_challenge_method,
      :code_challenge,
      :me,
      :redirect_uri,
      :response_type,
      :scope,
      :state
    )
  end

  def client_metadata
    @client_metadata ||= ClientMetadataService.new.fetch_client_metadata(authorization_request.me)
  end
end
