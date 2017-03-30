class Api::ContributionsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.contributions.includes(:project, :matcher, :payment)
  end

  def show
    contribution = current_user.contributions.find(params[:id])
    payment = contribution.payment

    if payment && (payment.status == 'CREATED')
      if payment.destroy
        logger.info 'Payment deleted'
      else
        handle_errors(payment)
      end
    end

    render json: contribution
  end

  def create
    contribution = current_user.contributions.build(build_params)
    if contribution.save
      render json: contribution
    else
      handle_errors(contribution)
    end
  end

  def update
    contribution = Contribution.find(params[:id])
    if contribution.payment #&& trip.payment.completed?
      logger.error 'Contribution already paid!'
    else
      if contribution.update(build_params)
        render json: contribution
      else
        handle_errors(contribution)
      end
    end
  end

  def destroy
    contribution = Contribution.find(params[:id])
    if contribution.destroy
      logger.info 'Contribution deleted'
      render json: nil, status: :ok
    else
      handle_errors(contribution)
    end
  end

  private
  def build_params
    if params[:contribution][:trip].nil?
      contribution_params
    else
      trip_attributes = {trip_attributes: trip_params}
      contribution_params.merge(trip_attributes)
    end
  end

  def trip_params
    params.require(:contribution).require(:trip).permit(:id, :origin, :origin_lat, :origin_lng, :destination, :destination_lat, :destination_lng, :length, :multiplier)
  end

  def contribution_params
    params.require(:contribution).permit(:title, :project_id, :matcher_id, :amount)
  end
end
