# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "videos")
Rails.application.config.assets.precompile += %w( 854401-hd_1280_720_30fps.mp4 3335294-hd_1920_1080_30fps.mp4 4125025-uhd_3840_2160_24fps.mp4 4125042-uhd_3840_2160_24fps.mp4 )
Rails.application.config.assets.precompile += %w( application.js )

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
