class UserSerializer < ActiveModel::Serializer
  embed :ids, include: false
  attributes :id, :name, :email, :contribution_visibility, :total_km, :total_don, :contributions_count, :profile_picture_url, :profile_picture_name

  def correct_user?
    options[:current_user] == object.id
  end

  def private?
    object.contribution_visibility == 'hidden'
  end

  def email
    if correct_user?
      object.email
    else
      ''
    end
  end

  def total_km
    if private? && !correct_user?
      -1
    else
      object.total_km
    end
  end

  def total_don
    if private? && !correct_user?
      -1
    else
      object.total_don
    end
  end

  def contributions_count
    if private? && !correct_user?
      -1
    else
      object.contributions_count
    end
  end

  # def trips
  #   if private? && !correct_user?
  #     []
  #   else
  #     object.trips
  #   end
  # end
end
