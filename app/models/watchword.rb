class Watchword < ActiveRecord::Base
  has_many :users
  validates :token, presence: true, length: { minimum: 1, maximum: 20 }, uniqueness: true
end
