class Api::GlobalsController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def show
    contributions_count = Contribution.paid_payment.length
    total_km = Trip.paid.map(&:length).reduce(0, :+).round(3).to_f
    total_don = Contribution.paid_payment.map(&:amount).reduce(0, :+).round(2).to_f
    globals = {contributions_count: contributions_count, total_km: total_km, total_don: total_don}
    render json: globals
  end
end
