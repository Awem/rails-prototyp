class ContributionSerializer < ActiveModel::Serializer
  embed :ids, include: false
  attributes :id, :title, :amount, :created_at
  has_one :project
  has_one :matcher
  has_one :user
  has_one :payment
  has_one :trip
end