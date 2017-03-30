class PaymentSerializer < ActiveModel::Serializer
  embed :ids, include: false
  attributes :id, :provider, :status, :matched, :paypal_key
  has_one :trip
end
