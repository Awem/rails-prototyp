class Project < ActiveRecord::Base
  has_many :partnerships, dependent: :destroy
  has_many :matching_partners, -> { uniq }, through: :partnerships, source: :matcher
  has_many :reverse_contributions, -> { paid_payment }, class_name: 'Contribution'
  has_many :supporting_partners, -> { uniq }, through: :reverse_contributions, source: :matcher
  has_many :pictures, as: :theme
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { case_sensitive: false }
  default_scope { order(id: :asc) }
  scope :featured_full, -> { where(featured: 'full') }

  def matching_partners_count
    self.matching_partners.length
  end

  def donated_contributions_count
    self.reverse_contributions.length
  end

  def supporting_partners_count
    self.supporting_partners.length
  end

  def matched_by?(matcher)
    partnerships.find_by(matcher_id: matcher.id)
  end

  def potential_partners
    Matcher.where.not(id: self.matching_partners.map(&:id))
  end

  def get_matched_by!(matcher)
    partnerships.create!(matcher_id: matcher.id)
  end

  def get_unmatched_by!(matcher)
    partnerships.find_by(matcher_id: matcher.id).destroy
  end

  def set_logo!(picture)
    self.logo = picture.id
    self.save
  end

  def logo_url
    if self.logo != 0
      Picture.find(self.logo).url
    end
  end

  def logo_name
    if self.logo != 0
      Picture.find(self.logo).name
    end
  end
end