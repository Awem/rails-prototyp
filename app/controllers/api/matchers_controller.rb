class Api::MatchersController < ApplicationController
  skip_before_filter :authenticate_user!
  def index
    if index_params[:featured] == 'campaign'
      matchers = Matcher.featured_campaign
    else
      matchers = Matcher.all
    end
    render json: matchers.includes(:matched_projects, :supported_projects)
  end

  def show
    render json: Matcher.find(params[:id])
  end

  private

  def index_params
    params.permit(:featured)
  end
end