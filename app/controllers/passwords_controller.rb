class PasswordsController  < Devise::PasswordsController
  respond_to :html, :json

  def create
    self.resource = resource_class.send_reset_password_instructions(request_params)

    if resource.errors.empty?
      logger.info resource
    else
      logger.info resource.errors
    end

    render json: {message: 'Request received'}, status: 200
  end

  def update
    self.resource = resource_class.reset_password_by_token(reset_params)
    if resource.errors.empty?
      render json: resource
    else
      handle_errors(resource)
    end
  end

  private

  def request_params
    params.permit(:email)
  end

  def reset_params
    params.permit(:reset_password_token, :password, :password_confirmation)
  end
end
