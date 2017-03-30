class Picture < ActiveRecord::Base
  belongs_to :theme, polymorphic: true
  include Gravatarify::Base
  mount_uploader :picture_asset, PictureAssetUploader
  validates :picture_asset, file_size: { less_than_or_equal_to: 400.kilobytes }
  before_save :update_picture_asset_attributes
  after_save :update_picture_asset_url

  def gravatar
    if self.theme_type == 'User'
      email = self.theme.email
      gravatar_url(email, {default: 'wavatar', size: 100, secure: true})
    else
      gravatar_url('', {size: 100, secure: true})
    end
  end

  private

  def update_picture_asset_attributes
    if picture_asset.present? && picture_asset_changed?
      self.content_type = picture_asset.file.content_type
      self.file_size = picture_asset.file.size
    end
  end

  def update_picture_asset_url
    if picture_asset.current_path
      update_column(:url, picture_asset.current_path)
    end
  end
end
