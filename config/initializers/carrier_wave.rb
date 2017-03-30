CarrierWave.configure do |config|
  config.cache_dir = "#{Rails.root}/tmp/uploads"
  config.fog_provider = 'fog/aws'                          # required
  config.fog_credentials = {
      provider:               'AWS',                       # required
      aws_access_key_id:      ENV['AWS_ACCESS_KEY_ID'],    # required
      aws_secret_access_key:  ENV['AWS_ACCESS_KEY'],       # required
      region:                 'eu-central-1',                # optional, defaults to 'us-east-1'
      # host:                  's3.example.com',             # optional, defaults to nil
      # endpoint:              'https://s3.example.com:8080' # optional, defaults to nil
  }
  config.fog_directory  = ENV['FOG_DIRECTORY']                             # required
  config.fog_public     = false                                            # optional, defaults to true
  config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" } # optional, defaults to {}
end