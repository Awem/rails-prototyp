class Api::GroupsController < ApplicationController
  skip_before_filter :authenticate_user!
  respond_to :json

  def index
    render json: Group.all, current_user: user_id
  end

  def show
    group = Group.find(params[:id])
    render json: group, current_user: user_id
  end

  def create
    group = Group.create(build_params)
    if group.save
      if current_user.join_group!(group, 'founder')
        render json: group, current_user: user_id
      else
        handle_errors(current_user)
      end
    else
      handle_errors(group)
    end
  end

  def update
    group = current_user.groups.find(params[:id])
    membership = current_user.memberships.find_by(group_id: group.id)
    if !(membership.role == 'founder' || membership.role == 'admin')
      group.errors.add(:editing, 'not allowed, sorry!')
      handle_errors(group)
    else
      if group.update(group_params)
        render json: group, current_user: user_id
      else
        handle_errors(group)
      end
    end
  end

  def destroy
    group = current_user.groups.find(params[:id])
    membership = current_user.memberships.find_by(group_id: group.id)
    if !(membership.role == 'founder' || membership.role == 'admin')
      group.errors.add(:editing, 'not allowed, sorry!')
      handle_errors(group)
    else
      if group.destroy
        logger.info 'group deleted'
        render json: nil, status: :ok
      else
        handle_errors(group)
      end
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

  def group_params
    params.require(:group).permit(:name, :description)
  end

  def build_params
    category = {category: 'public'}
    merged_params = group_params.merge(category)
    merged_params.permit(:name, :description, :category)
  end
end