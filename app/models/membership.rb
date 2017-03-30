class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  validates :user_id, presence: true
  validates :group_id, presence: true
  validates :role, presence: true
  scope :valid, -> { where.not(role: 'pending') }
  scope :pending, -> { where(role: 'pending') }
  scope :admin, -> { where(role: ['founder', 'admin']) }
end
