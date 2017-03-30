class ErrorsSerializer < ActiveModel::Serializer
  def serialize(errors)
    return if errors.nil?

    errors.to_hash(true).map do |key, message|
      {
          id: key,
          title: message.join(". ") + "."
      }
    end.flatten
  end

  def serializable_hash
    serialize(object)
  end
end
