class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :trips, through: :contributions, dependent: :destroy
  has_many :contributions, dependent: :destroy
  has_many :payments, through: :contributions, source: :payment
  has_many :pictures, as: :theme
  has_many :memberships, dependent: :destroy
  has_many :staff_memberships, -> { admin }, class_name: 'Membership'
  has_many :groups, :through => :memberships
  has_many :administered_groups, through: :staff_memberships, source: :group
  belongs_to :watchword
  before_save { self.email = email.downcase }
  before_save :ensure_authentication_token
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }, uniqueness: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  default_scope { order(id: :asc) }
  scope :fully_sharing, -> { where(contribution_visibility: 'full') }
  attr_accessor :invite
  validate :invite_valid, on: :create

  def invite_valid
    unless Watchword.where(token: self.invite).take
      self.errors.add(:invite, 'invalid.  Ask for another code or try again.')
    end
  end


  def contributions_count
    self.contributions.paid_payment.length
  end

  def total_km
    self.trips.paid.map(&:length).reduce(0, :+).round(3).to_f
  end

  def total_don
    self.contributions.paid_payment.map(&:amount).reduce(0, :+).round(2).to_f
  end

  def get_gravatar!
    picture = self.pictures.build
    picture.url = picture.gravatar
    picture.name = 'gravatar'
    picture.save
    self.set_profile_picture!(picture)
  end

  def set_profile_picture!(picture)
    self.profile_picture = picture.id
    self.save
  end

  def profile_picture_url
    if self.profile_picture != 0
      Picture.find(self.profile_picture).url
    end
  end

  def profile_picture_name
    if self.profile_picture != 0
      Picture.find(self.profile_picture).name
    end
  end

  def self.sorted_by_total_don
    User.all.sort_by(&:total_don).reverse
  end

  def found_group!(name, description = nil, category = 'public')
    group = Group.create!(name: name, category: category, description: description)
    self.join_group!(group, 'founder')
  end

  def join_group!(group, role = 'pending')
    if group.membership_status(self) == 'forbidden'
      self.errors.add(:joining, 'this group is restricted, sorry!')
      false
    else
      self.memberships.create!(group: group, role: role)
    end
  end

  def leave_group!(group)
    membership = self.memberships.find_by(group_id: group.id)
    if membership
      if membership.role == 'founder'
        group.errors.add(:leaving, 'a group that you founded is not allowed, sorry! Delete it instead')
        false
      else
        membership.destroy!
      end
    else
      group.errors.add(:leaving, 'a group that you are not a member of is impossible, of course')
      false
    end
  end

  def is_member?(group)
    self.memberships.find_by(group_id: group.id).present?
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end