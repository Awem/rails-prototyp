class ApplicationController < ActionController::API
  # add to Rails-API:
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_filter :authenticate_user_from_token!
  # Enter the normal Devise authentication path,
  # using the token authenticated user if available
  before_filter :authenticate_user!

  private
  def authenticate_user_from_token!
    authenticate_with_http_token do |token, options|
      user_email = options[:email].presence
      user       = user_email && User.find_by_email(user_email)

      if user && Devise.secure_compare(user.authentication_token, token)
        sign_in user, store: false
      end
    end
  end

  def handle_errors(object)
    logger.error object.errors.full_messages
    render json: object.errors, serializer: ErrorsSerializer, status: :unprocessable_entity
  end
end
