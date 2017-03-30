class MatcherSerializer < ActiveModel::Serializer
  embed :ids, include: false
  attributes :id, :name, :description, :matched_projects_count, :supported_contributions_count, :supported_projects_count, :matching_factors, :logo_url, :logo_name, :total_budget, :remaining_budget
  has_many :matched_projects
  has_many :supported_projects
end
