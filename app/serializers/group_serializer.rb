class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: false
  attributes :id, :name, :category, :description, :membership_status, :total_km, :total_don, :contributions_count, :membership_with, :logo_url
  has_many :affiliations
  has_many :applications

  def member?
    object.users.ids.include? options[:current_user]
  end

  def admin?
    object.admins.ids.include? options[:current_user]
  end

  def membership_with
    object.membership_with(options[:current_user])
  end

  def membership_status
    object.membership_status(options[:current_user])
  end

  def affiliations
    if member? || object.category == 'public'
      object.affiliations
    else
      []
    end
  end

  def applications
    if admin?
      object.applications
    else
      []
    end
  end
end