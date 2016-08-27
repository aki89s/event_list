
if Rails.env.test? || Rails.env.development?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: '',
      aws_secret_access_key: '',
      region: 'ap-northeast-1'
    }
    config.fog_directory  = 'echat'
  end
end
if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_S3_KEY_ID'],
      aws_secret_access_key: ENV['AWS_S3_SECRET_KEY'],
      region: 'ap-northeast-1'
    }
    config.fog_directory  = ENV['AWS_S3_BUCKET']
  end
end
