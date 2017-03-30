class MembershipSerializer < ActiveModel::Serializer
  embed :ids, include: false
  attributes :id, :role
  has_one :user
  has_one :group

  def may_see_as?(user_role)
    group = Group.find(object.group_id)
    if group.category == 'public' && object.role != 'pending'
      true
    else
      case user_role
        when 'admin'
          group.admins.ids.include? options[:current_user]
        when 'member'
          group.admins.ids.include? options[:current_user]
        else
          false
      end
    end
  end

  def user
    if (object.role == 'pending' && may_see_as?('admin')) || (object.role != 'pending' && may_see_as?('user'))
      object.user
    else
      nil
    end
  end

  def group
    if (object.role == 'pending' && may_see_as?('admin')) || (object.role != 'pending' && may_see_as?('user'))
      object.group
    else
      nil
    end
  end

  def role
    if (object.role == 'pending' && may_see_as?('admin')) || (object.role != 'pending' && may_see_as?('user'))
      object.role
    else
      nil
    end
  end
end