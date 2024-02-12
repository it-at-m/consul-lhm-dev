# Be sure to restart your server when you modify this file.

Rails.application.config.assets.precompile += Dir.glob("#{Rails.root}/app/assets/javascripts/cli/**/*.js")

Rails.application.config.assets.precompile += Dir.glob("#{Rails.root}/app/assets/javascripts/ckeditor/plugins/**/*.js")
Rails.application.config.assets.precompile += Dir.glob("#{Rails.root}/app/assets/javascripts/ckeditor/plugins/**/*.png")
Rails.application.config.assets.precompile += Dir.glob("#{Rails.root}/app/assets/javascripts/ckeditor/plugins/**/*.css")

Rails.application.config.assets.precompile += %w[sdg/*.png]
Rails.application.config.assets.precompile += %w[sdg/**/*.png]
Rails.application.config.assets.precompile += %w[sdg/**/*.svg]

# Loads custom images and custom fonts before app/assets/images and app/assets/fonts
