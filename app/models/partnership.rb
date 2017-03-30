class Partnership < ActiveRecord::Base
  belongs_to :project
  belongs_to :matcher
  validates :project_id, presence: true
  validates :matcher_id, presence: true
  validates :factor, presence: true
end
