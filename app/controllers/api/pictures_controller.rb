class Api::PicturesController < ApplicationController
  def upload
    target = params[:picture]
    file = params[:file].tempfile
    model_id = params[:modelId]
    original_filename = params[:name]
    case target
      when 'profile'
        picture = current_user.pictures.build(original_filename: original_filename)
        self.upload_profile_picture(picture, file)
      when 'group'
        group = current_user.administered_groups.find(model_id)
        picture = group.pictures.build(original_filename: original_filename)
        self.upload_group_picture(picture, file, group)
      else
        picture = current_user.pictures.build(original_filename: original_filename)
        picture.errors.add(:target, 'unknown. What is this picture for?')
        handle_errors(picture)
    end
  end

  def upload_profile_picture(picture, file)
    picture.name = 'profile'
    picture.picture_asset = file
    if picture.save
      current_user.set_profile_picture!(picture)
      render json: picture
    else
      handle_errors(picture)
    end
  end

  def upload_group_picture(picture, file, group)
    picture.name = 'group'
    picture.picture_asset = file
    if picture.save
      group.set_logo!(picture)
      render json: picture
    else
      handle_errors(picture)
    end
  end
end