class Trip < ActiveRecord::Base
  belongs_to :contribution
  has_one :user, through: :contribution, source: :user
  has_one :project, through: :contribution, source: :project
  has_one :matcher, through: :contribution, source: :matcher
  has_one :payment, through: :contribution, source: :payment
  default_scope -> { order('created_at DESC') }
  validates :origin_lat, :origin_lng, :destination_lat, :destination_lng, presence: true, numericality: true
  validates :length, presence: true, numericality: { greater_than: 0, less_than: 25000 }
  validates :multiplier, presence: true, numericality: { greater_than: 0, less_than: 1000000 }
  scope :paid, -> { where(contribution_id: Contribution.paid_payment.ids) }
  scope :unpaid, -> { where.not(contribution_id: Contribution.paid_payment.ids) }
end
