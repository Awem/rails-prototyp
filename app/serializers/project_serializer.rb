class ProjectSerializer < ActiveModel::Serializer
  embed :ids, include: false
  attributes :id, :name, :description, :matching_partners_count, :donated_contributions_count, :supporting_partners_count, :logo_url, :logo_name
  has_many :matching_partners
  has_many :supporting_partners
end
