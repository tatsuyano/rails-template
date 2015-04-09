# -*- coding: utf-8 -*-

@app_name = app_name

gem 'rails', '4.2.1'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'annotate' # modelクラスにスキーマ情報の注釈をつける
gem 'bootstrap-sass' # bootstrap
gem 'rails_config'

gem_group :development, :test do
  gem 'spring'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rspec-rails'
  gem 'guard-rspec'                        # railsでguardを使うためのGem
  gem 'spring-commands-rspec' , '~> 1.0.2' # springでキャッシュした状態でguardを使うためのGem
  gem "factory_girl_rails" , "~> 4.4.1"    # テストデータの作成
end

gem_group :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'shoulda-matchers', require: false # rspecで使うmatcher
  gem "faker" , "~> 1.4.3"              # 名前やメールアドレス、その他のプレースホルダをファクトリに提供
  gem "database_cleaner" , "~> 1.3.0"   # まっさらな状態で各specが実行できるように、テストデータベースのデータを掃除
#  gem "capybara" , "~> 2.4.3"           # ユーザとWebアプリケーションのやりとりをプログラム上でシミュレートできる
#  gem "launchy" , "~> 2.4.2"            # 好きなタイミングでデフォルトのwebブラウザを開く
#  gem "selenium-webdriver" , "~> 2.43.0"# ブラウザ上でJavaScriptを利用する機能をCapybaraでテストできる
end

gem_group :production do
  gem 'rails_12factor'
end

# rspec initalize setting
run 'bundle install'
run 'rm -rf test'
generate 'rspec:install'

# guard initalize setting
run 'bundle exec spring binstub rspec'
run 'bundle exec guard init rspec'

# rm unused files
run "rm README.rdoc"

# railsconfig
run "rails g rails_config:install"

# database
run 'rm config/database.yml'

database_yml = <<-FILE
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5

development:
  <<: *default
  database: #{@app_name}
  username: postgres
  password: postgres

test:
  <<: *default
  database: #{@app_name}_test
  username: postgres
  password: postgres
FILE
  
File.open("config/database.yml","w") do |file|
  file.puts database_yml
end

run 'bundle exec rake db:create'
run 'rails g annotate:install'

# set config/application.rb
application  do
  %q{
    # Set timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # 日本語化
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja

    # generatorの設定
    config.generators do |g|
      g.orm :active_record
      g.assets false
      g.helper false

      # RSpec
      g.test_framework  :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      g.view_specs false
      g.controller_specs true
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
    end
  }
end

# i18(ja)
File.open("config/locales/ja.yml","w") do |file|
  file.puts <<-JA_YML
ja:
  hello: "こんにちは"
JA_YML
end

# bootstrap
run "rm app/assets/stylesheets/application.css"
run "rm app/assets/javascripts/application.js"
run 'mkdir -p app/assets/stylesheets/partials/'

# generatorでcssを生成しないようにしたため、partialsディレクトリ配下にファイルが一つもないと
# File to import not found or unreadable エラーが出てしまうので、それを防ぐためにブランクのscssを配置する。
# partialsにページ固有のscssファイルを配置した後は、blank.scssは削除など対応する
run 'touch app/assets/stylesheets/partials/blank.scss'

@repo_url = 'https://raw.githubusercontent.com/tatsuyano/rails-template/master'
run "wget #{@repo_url}/app/assets/stylesheets/_bootstrap-custom.scss -P app/assets/stylesheets/"
run "wget #{@repo_url}/app/assets/javascripts/bootstrap-sprockets-custom.js -P app/assets/javascripts/"

File.open("app/assets/stylesheets/application.scss","w") do |file|
  file.puts <<-SCSS
@import "bootstrap-sprockets";
@import "bootstrap-custom";
@import "partials/*";
SCSS
end

File.open("app/assets/javascripts/application.js","w") do |file|
  file.puts <<-JS
//= require jquery
//= require bootstrap-sprockets-custom
JS
end

# git initalize setting
after_bundle do
  git :init
  git add: '.'
  git commit: %Q{ -m 'Initial commit' }
end
