# ３章: サインアップ・サインイン機能

## 3-1 Deviseの導入

### 1. DeviseのGemをインストール

+ [devise](https://github.com/plataformatec/devise) <br>

+ `Gemfile`を編集<br>

```:Gemfile
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.7'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'devise' # 追加
```

+ `$ bundle install`を実行<br>

+ `$ rails generate devise:install`を実行<br>

### 2. Deviseのフラッシュメッセージを追加

+ `app/views/layouts/application.html.erb`を編集<br>

```html:application.html.erb
<!DOCTYPE html>
<html>

<head>
  <title>App</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
  <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

  <%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
</head>

<body>
  <%= render 'partial/navbar' %>

  <!-- 追加 -->
  <% if flash[:notice] %>
  <div class="alert alert-info">
    <%= flash[:notice] %>
  </div>
  <% end %>
  <% if flash[:alert] %>
  <div class="alert alert-danger">
    <%= flash[:alert] %>
  </div>
  <% end %>
  <!-- ここまで -->

  <%= yield %>
</body>

</html>
```

+ `$ rails g devise:views`を実行<br>

### 4. Userモデルを作成

+ `$ rails g devise User`を実行<br>

### 5. Usersテーブルを作成

+ `$ rails db:migrate`を実行<br>

+ サーバーを再起動する<br>

+ localhost:3000/users/sign_up にアクセスしてみる<br>

### 7. ナビゲーションヘッダーの非表示

+ [Rails deviseで使えるようになるヘルパーメソッド一覧](https://qiita.com/tobita0000/items/866de191635e6d74e392) <br>

+ `app/views/layouts/application.html.erb`を編集<br>

```html:application.html.erb
<!DOCTYPE html>
<html>

<head>
  <title>App</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
  <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

  <%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
</head>

<body>
  <%= render 'partial/navbar' if current_user %> <!-- 編集 ログインしていない場合はナビバーは非表示 -->

  <% if flash[:notice] %>
  <div class="alert alert-info">
    <%= flash[:notice] %>
  </div>
  <% end %>
  <% if flash[:alert] %>
  <div class="alert alert-danger">
    <%= flash[:alert] %>
  </div>
  <% end %>

  <%= yield %>
</body>

</html>
```

## 3-2 実際にユーザーの新規登録ができるか確認

+ ユーザー登録してログインしてみる(できたらOK)<br>

### 2. 登録したユーザーのレコードを取得

+ `$ rails console`を実行<br>

+ `irb(main):001:0> User.first`を実行<br>

```:terminal
irb(main):001:0> User.first
  User Load (2.1ms)  SELECT `users`.* FROM `users` ORDER BY `users`.`id` ASC LIMIT 1
=> #<User id: 1, email: "takaki55730317@gmail.com", created_at: "2022-09-14 12:17:43.840313000 +0000", updated_at: "2022-09-14 12:17:43.840313000 +0000">
irb(main):002:0>
```

+ [Rails ドキュメント first](http://railsdoc.com/references/first) <br>

## 3-3 サインアウトリンクの追加

+ [link_toメソッドを使ったリンクの作成](https://www.javadrive.jp/rails/template/index8.html) <br>

+ サインアウトのルーティング<br>

```
destroy_user_session DELETE /users/sign_out(.:format)   devise/sessions#destroy
```

+ `app/views/pages/home.html.erb`を編集<br>

```html:home.html.erb
<%= link_to "サインアウト", destroy_user_session_path, method: :delete %> <!-- 追加 -->

<p>ここのページは仮のトップページです。</p>

<%= link_to "仮のボタンです", "#", class: "btn btn-primary" %>
```

+ サインアウトしてみる<br>

### 2. サインインしていないときはサインアウトリンクを非表示

+ `app/views/pages/home.html.erb`を編集<br>

```html:home.html.erb
<% if user_signed_in? %> <!-- 追加 もしサインインしていたらサインアウトリンクは表示されない -->
<%= link_to "サインアウト", destroy_user_session_path, method: :delete %>
<% end %> <!-- 追加 -->

<p>ここのページは仮のトップページです。</p>

<%= link_to "仮のボタンです", "#", class: "btn btn-primary" %>
```

+ [Rails deviseで使えるようになるヘルパーメソッド一覧](https://qiita.com/tobita0000/items/866de191635e6d74e392) <br>

## 3-4 usersテーブルにnameカラムを追加

+ [devise にusername カラムを追加し、usernameを登録できるようにする。](https://qiita.com/yasuno0327/items/ff17ddb6a4167fc6b471) <br>


### 1. カラムを追加するためのマイグレーションファイルの作成

+ [rails generate migrationコマンドまとめ](https://qiita.com/zaru/items/cde2c46b6126867a1a64) <br>

+ `$ rails g migration AddNameToUser name:string`を実行<br>

+ `db/migrate/add_name_to_user.rb`を編集(null: falseでNULLを禁止)<br>

```rb:add_name_to_user.rb
class AddNameToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string, null: false # 編集
  end
end
```

### 2. マイグレーションファイルを実行

+ `$ rails db:migrate`を実行<br>

### 3. バリデーションの設定

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 50 } # 追加
end
```

+ [Active Record バリデーション](https://railsguides.jp/active_record_validations.html) <br>

### 4. nameカラムを保存できるようにする

+ [Rails初学者がつまずきやすい「ストロングパラメータの仕組み」](https://www.transnet.ne.jp/2016/05/18/rails%E5%88%9D%E5%AD%A6%E8%80%85%E3%82%B9%E3%83%88%E3%83%AD%E3%83%B3%E3%82%B0%E3%83%91%E3%83%A9%E3%83%A1%E3%83%BC%E3%82%BF%E3%83%BCcolnr/) <br>

+ `app/controllers/application_controller.rb`を編集<br>

```rb:application_controller.rb
class ApplicationController < ActionController::Base

  # 追加
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  # ここまで
end
```

+ [クロスサイトリクエストフォージェリ (CSRF)](https://railsguides.jp/security.html#%E3%82%AF%E3%83%AD%E3%82%B9%E3%82%B5%E3%82%A4%E3%83%88%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88%E3%83%95%E3%82%A9%E3%83%BC%E3%82%B8%E3%82%A7%E3%83%AA-csrf) <br>

+ [Devise - Strong Parameters](https://github.com/plataformatec/devise#strong-parameters) <br>

## 3-5 サインアップ画面の見た目を整える

### 1. サインアップ画面のビューを作成

+ `app/views/devise/registrations/new.html.erb`を編集<br>

```html:new.html.erb
<div class="main">
  <div class="card devise-card">
    <div class="form-wrap">
      <div class="form-group text-center">
        <h2 class="logo-img mx-auto"></h2>
        <p class="text-secondary">友達の写真や動画をチェックしよう</p>
      </div>
      <%= form_with scope: resource, as: resource_name, url: registration_path(resource_name), local: true do |f| %>
      <div class="form-group">
        <%= f.email_field :email, autofocus: true, placeholder: "メールアドレス", class: "form-control" %>
      </div>

      <div class="form-group">
        <%= f.text_field :name, autofocus: true, placeholder: "フルネーム", class: "form-control" %>
      </div>

      <div class="form-group">
        <%= f.password_field :password, autocomplete: "off", placeholder: "パスワード", class: "form-control" %>
      </div>

      <div class="form-group">
        <%= f.password_field :password_confirmation, autocomplete: "off", placeholder: "パスワードの確認", class: "form-control" %>
      </div>

      <div class="actions">
        <%= f.submit "登録する", class: "btn btn-primary w-100" %>
      </div>
      <% end %>

      <br>

      <p class="devise-link">
        アカウントをお持ちですか？
        <%= link_to "サインインする", new_user_session_path %>
      </p>
    </div>
  </div>
</div>
```

+ [Bootstrap公式ドキュメント](https://getbootstrap.com/) <br>

### 2. scssファイルをインポート

+ `app/javascript/stylesheets/application.scss`を編集<br>

```scss:application.scss
@import '~bootstrap/scss/bootstrap';
@import 'layouts/navbar';
@import 'common'; // 追加
@import 'users/devise'; // 追加
```

### 3. サインアップ画面のscssを追加

+ `$ touch app/javascript/stylesheets/common.scss`を実行<br>

+ `app/javascript/stylesheets/common.scss`を編集<br>

```scss:common.scss
body {
  background-color: #fafafa;
  font-size: 14px;
  color: #262626;
}
```

+ `$ mkdir app/javascript/stylesheets/users && touch $_/devise.scss`を実行<br>

+ `app/javascript/stylesheets/users/devise.scss`を編集<br>

```scss:devise.scss
.main {
  max-width: 960px;
  margin: 0 auto;
  width: 90%;
  padding: 100px 75px 100px;
  display: block;
  flex: 1;
  flex-basis: auto;
  box-sizing: border-box;
}

.devise-card {
  border: none;
}

.form-wrap {
  max-width: 400px;
  width: 100%;
  margin: 50px auto;
}

.logo-img {
  background-image: url('~logo.png');
  background-repeat: no-repeat;
  height: 56px;
  width: 180px;
  background-size: 160px;
  background-size: 180px !important;
}

.form-control {
  border: 1px solid #dcdfe6;
  font-size: inherit;
}

.devise-link {
  text-align: center;
  margin: 16px 0;
}

#wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

footer {
  margin-top: auto;
}

@media screen and (max-width: 768px) {
  .main {
    padding: 75px 0;
  }
  .devise-card {
    background-color: #fafafa;
  }
}
```

### 4. footerの作成

+ `app/views/layouts/application.html.erb`を編集<br>

```html:application.html.erb
<!DOCTYPE html>
<html>

<head>
  <title>App</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
  <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

  <%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
</head>

<body>
  <div id="wrapper"> <!-- 追加 -->
    <%= render 'partial/navbar' if current_user %>

    <% if flash[:notice] %>
    <div class="alert alert-info">
      <%= flash[:notice] %>
    </div>
    <% end %>
    <% if flash[:alert] %>
    <div class="alert alert-danger">
      <%= flash[:alert] %>
    </div>
    <% end %>

    <%= yield %>

    <%= render 'partial/footer' %> <!-- 追加 -->
  </div> <!-- 追加 -->
</body>

</html>
```

+ `$ touch app/views/partial/_footer.html.erb`を実行<br>

+ `app/views/partial/_footer.html.erb`を編集<br>

```html:_footer.html.erb
<footer>
  <div class="container">
    <div class="text-center">
      <p>
        Copyright ©︎ Techpit
      </p>
    </div>
  </div>
</footer>
```

+ http://localhost:3000/users/sign_up にアクセスしてみる<br>