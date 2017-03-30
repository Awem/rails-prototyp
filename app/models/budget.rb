class Budget < ActiveRecord::Base
  belongs_to :matcher
  has_many :contributions
  validates :matcher_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  scope :in_effect, -> { where(effective: true) }

  def remains
    contributed = self.contributions.paid_payment.map(&:amount).reduce(0, :+).round(2).to_f
    self.amount - contributed
  end
end
