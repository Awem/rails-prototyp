class Api::ProjectsController < ApplicationController
  skip_before_filter :authenticate_user!
  def index
    if index_params[:featured] == 'full'
      projects = Project.featured_full
    else
      projects = Project.all
    end
    render json: projects.includes(:matching_partners, :supporting_partners)
  end

  def show
    render json: Project.find(params[:id])
  end

  private

  def index_params
    params.permit(:featured)
  end
end