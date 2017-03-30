class Api::PaymentsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.payments
  end

  def show
    payment = current_user.payments.find(params[:id])

    if payment.status == 'CREATED'

      payment = payment.check

      if payment.errors.empty?
        render json: payment

        if payment.status == 'aborted'
          if payment.destroy
            logger.info 'Payment deleted'
          else
            handle_errors(payment)
          end
        end
      else
        handle_errors(payment)
      end

    else
      render json: payment
    end
  end

  def create
    contribution = current_user.contributions.find(payment_params['contribution_id'])
    payment = contribution.pay(payment_params)

    if payment
      if payment.save
        render json: payment
      else
        handle_errors(payment)
      end
    else
      handle_errors(contribution)
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:provider, :contribution_id)
  end
end
