class Api::MembershipsController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def index
    render json: Membership.all, current_user: user_id
  end

  def show
    render json: Membership.find(params[:id]), current_user: user_id
  end

  def create
    group = Group.find(params[:membership][:group_id])
    role = 'pending'
    if current_user.join_group!(group, role)
      membership = current_user.memberships.find_by(group_id: group.id)
      render json: membership
    else
      handle_errors(current_user)
    end
  end

  def update
    membership = Membership.find(params[:id])
    role = params[:membership][:role]
    group = membership.group
    user = membership.user
    case role
      when 'member'
        if group.accept_application_from!(user)
          render json: membership
        else
          handle_errors(group)
        end
      else
        membership.errors.add(:role, 'is not allowed')
        handle_errors(membership)
    end
  end

  def destroy
    membership = Membership.find(params[:id])
    user = membership.user
    group = membership.group
    if (group.admins.ids.include? current_user.id) || user.id == current_user.id
      if user.leave_group!(group)
        logger.info 'membership deleted'
        render json: nil, status: :ok
      else
        handle_errors(group)
      end
    else
      membership.errors.add(:destroying, 'this membership is not allowed for you')
      handle_errors(membership)
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
end