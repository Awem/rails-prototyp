class ConfirmationsController < Devise::ConfirmationsController
  respond_to :html, :json

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      render json: resource
    else
      handle_errors(resource)
    end
  end
end