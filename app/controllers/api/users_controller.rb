class Api::UsersController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def index
    if index_params[:top]
      top = index_params[:top].to_i
      users = User.fully_sharing.includes(:trips).sorted_by_total_don.take(top)
    else
      users = User.all.includes(:trips)
    end
    render json: users, current_user: user_id
  end

  def show
    render json: User.find(params[:id]), current_user: user_id
  end

  def create
    user = User.create(user_params)
    watchword = Watchword.where(token: user_params[:invite]).take
    user.watchword = watchword
    if user.save
      return render json: user
    end
    handle_errors(user)
  end

  def update
    user = User.find(params[:id])
    if user.update(settings_params)
      render json: user
    else
      handle_errors(user)
    end
  end
  private

  def user_id
    if current_user
      current_user.id
    else
      0
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :invite)
  end

  def settings_params
    params.require(:user).permit(:name, :email, :password, :contribution_visibility)
  end

  def index_params
    params.permit(:top)
  end
end
