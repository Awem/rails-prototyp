class Group < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :affiliations, -> { valid }, class_name: 'Membership', dependent: :destroy
  has_many :applications, -> { pending }, class_name: 'Membership', dependent: :destroy
  has_many :staff_memberships, -> { admin }, class_name: 'Membership', dependent: :destroy
  has_many :users, through: :memberships
  has_many :affiliates, through: :affiliations, source: :user
  has_many :applicants, through: :applications, source: :user
  has_many :admins, through: :staff_memberships, source: :user
  has_many :trips, through: :affiliates
  has_many :contributions, through: :affiliates
  has_many :pictures, as: :theme
  validates :name, presence: true
  validates :category, presence: true

  def contributions_count
    self.contributions.paid_payment.length
  end

  def total_km
    self.trips.paid.map(&:length).reduce(0, :+).round(3).to_f
  end

  def total_don
    self.contributions.paid_payment.map(&:amount).reduce(0, :+).round(2).to_f
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

  def non_members
    User.where.not(id: self.users.ids)
  end

  def membership_with(user = nil)
    membership = self.memberships.find_by(user_id: user)
    if membership.present?
      membership.id
    else
      0
    end
  end

  def membership_status(user = nil)
    membership = self.memberships.find_by(user_id: user)
    if membership.present?
      membership.role
    else
      if self.category == 'public'
        'possible'
      else
        'forbidden'
      end
    end
  end

  def accept_application_from!(user)
    membership = self.memberships.find_by(user_id: user.id)
    if membership.present?
      membership.update(role: 'member')
    else
      self.errors.add(:accpeting, 'this user is not possible, because he did not apply for membership')
      false
    end
  end
end
