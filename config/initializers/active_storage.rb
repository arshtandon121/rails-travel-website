Rails.application.config.after_initialize do
  ActiveStorage::Current.url_options = { host: 'localhost', port: 3000 } # for development
  ActiveStorage::Current.url_options = { host: 'http://13.211.16.26' } # for production

end


