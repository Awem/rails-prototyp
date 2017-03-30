class Api::TripsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.trips.includes(:project, :matcher, :payment)
  end

  def show
    render json: current_user.trips.find(params[:id])
  end
end
