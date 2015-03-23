# -*- coding: utf-8 -*-

@app_name = app_name

gem 'rails', '4.2.0'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
#gem 'turbolinks'
gem 'jbuilder', '~> 2.0'

# Bootstrap3
gem 'therubyracer'
gem 'less-rails'
gem 'twitter-bootstrap-rails'

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

# config/application
environment "config.time_zone = 'Tokyo'"
environment "config.active_record.default_timezone = :local"

# bootstrap
generate 'bootstrap:install'
generate 'bootstrap:layout application'

# git initalize setting
after_bundle do
  git :init
  git add: '.'
  git commit: %Q{ -m 'Initial commit' }
end
