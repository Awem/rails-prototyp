class TripSerializer < ActiveModel::Serializer
  embed :ids, include: false
  attributes :id, :origin, :destination, :origin_lat, :origin_lng, :destination_lat, :destination_lng, :length, :multiplier, :created_at
  has_one :payment
end