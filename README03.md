## 3-6 サインイン画面の見た目を整える

### 1. サインイン画面のビューを作成

+ `app/views/devise/sessions/new.html.erb`を編集<br>

```html:new.html.erb
<div class="main">
  <div class="card devise-card">
    <div class="form-wrap">
      <div class="form-group text-center">
        <h2 class="logo-img mx-auto"></h2>
      </div>
      <%= form_with scope: resource, as: resource_name, url: session_path(resource_name), local: true do |f| %>
      <%= devise_error_messages! %>
      <div class="form-group">
        <%= f.email_field :email, autofocus: true, placeholder: "メールアドレス", class: "form-control" %>
      </div>

      <div class="form-group">
        <%= f.password_field :password, autocomplete: "off", placeholder: "パスワード", class: "form-control" %>
      </div>

      <div class="actions">
        <%= f.submit "ログインする", class: "btn btn-primary w-100" %>
      </div>
      <% end %>

      <br>

      <p class="devise-link">
        アカウントをお持ちですか？
        <%= link_to "登録する", new_user_registration_path %>
      </p>
    </div>
  </div>
</div>
```

+ http://localhost:3000/users/sign_in にアクセスしてみる<br>

# 4章 ユーザープロフィール機能

## 4-1 プロフィールページの作成

### 1. プロフィールページのルーティングの追加

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  devise_for :users
  root 'pages#home'

  get '/users/:id', to: 'users#show', as: 'user' # 追加 user_pathになる
end
```

+ [名前付きルーティング](https://railsguides.jp/routing.html#%E5%90%8D%E5%89%8D%E4%BB%98%E3%81%8D%E3%83%AB%E3%83%BC%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0) <br>

```
user GET    /users/:id(.:format)  users#show
```

### 2. コントローラの作成

+ `$ rails g controller users`を実行<br>

### 3. 作成したコントローラにアクションを追加

+ `app/controllers/users_controller.rb`を編集<br>

```rb:users_controller.rb
class UsersController < ApplicationController

  def show
    @user = User.find_by(id: params[:id])
  end
end
```

+ [クラスの概念](https://www.javadrive.jp/ruby/class/) <br>

### 4. profile_photoカラムを追加

+ `$ rails g migration AddProfilePhotoToUsers profile_photo:string`を実行<br>

+ `$ rails db:migrate`を実行<br>

### profile_photoカラムに何もない場合、デフォルトのアイコンを表示

+ `app/helpers/application_helper.rb`を編集<br>

```rb:application_helper.rb
module ApplicationHelper

  def avatar_url(user)
    return user.profile_photo unless  user.profile_photo.nil?
      gravatar_id = Digest::MD5::hexdigest(user.email).downcase
      "https://techpit-market-prod.s3.amazonaws.com/uploads/part_attachment/file/15782/2da91636-af73-4eed-91cd-320a0399609c.jpg"
  end
end
```

+ `app/views/layouts/application.html.erb`を編集<br>

```html:application.html.erb
<!DOCTYPE html>
<html>

<head>
  <title>Techpitgram</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
  <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

  <%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
</head>

<body>
  <div id="wrapper">
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

    <!-- 編集 -->
    <div class="container">
      <%= yield %>
    </div>
    <!-- ここまで -->

    <%= render 'partial/footer' %>
  </div>
</body>

</html>
```

+ [Grid system](https://getbootstrap.com/docs/4.0/layout/grid/) <br>

+ `$ touch app/views/users/show.html.erb`を実行<br>

+ `app/views/users/show.html.erb`を編集<br>

```html:show.html.erb
<div class="profile-wrap">
  <div class="row">
    <div class="col-md-4 text-center">
      <%= image_tag avatar_url(@user), class: "round-img" %>
    </div>
    <div class="col-md-8">
      <div class="row">
        <h1><%= @user.name %></h1>
        <%= link_to "プロフィールを編集", edit_user_registration_path, class: "btn btn-outline-dark common-btn edit-profile-btn" %>
        <button type="button" class="setting" data-toggle="modal" data-target="#exampleModal"></button>

        <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
          aria-hidden="true">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">設定</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">X</span>
                </button>
              </div>
              <div class="list-group text-center">
                <%= link_to "サインアウト", destroy_user_session_path, method: :delete, class: "list-group-item list-group-item-action" %>
                <%= link_to "キャンセル", "#", class: "list-group-item list-group-item-action", "data-dismiss": "modal" %>
              </div>
            </div>
          </div>
        </div>
      </div>
      <% if @user == current_user %>
      <div class="row">
        <p>
          <%= @user.email %>
        </p>
      </div>
      <% end %>
    </div>
  </div>
</div>
```

+ `app/javascript/stylesheets/application.scss`を編集<br>

```scss:application.scss
@import '~bootstrap/scss/bootstrap';
@import 'layouts/navbar';
@import 'common';
@import 'users/devise';
@import 'users/show'; // 追加
```

+ `$ touch app/javascript/stylesheets/users/show.scss`を実行<br>

+ `app/javascript/stylesheets/users/show.scss`を編集<br>

```scss:show.scss
.profile-wrap {
  margin: 40px 0px;
}

.round-img {
  border-radius: 50%;
  width: 120px;
  height: 120px;
}

.edit-profile-btn {
  margin: 15px 0 0 15px;
  font-weight: bold;
  height: 26px;
  line-height: 26px;
  padding: 0 26px;
  border-color: #dbdbdb;
  font-size: 14px;
}

.setting {
  background-image: url('~parts4.png');
  background-repeat: no-repeat;
  height: 24px;
  width: 24px;
  background-color: transparent;
  margin: 18px 0 0 10px;
  background-size: 22px !important;
  border: none;
  &:hover {
    cursor: pointer;
  }
}
```

+ [データベースをリセットする](https://railsguides.jp/active_record_migrations.html#%E3%83%87%E3%83%BC%E3%82%BF%E3%83%99%E3%83%BC%E3%82%B9%E3%82%92%E3%83%AA%E3%82%BB%E3%83%83%E3%83%88%E3%81%99%E3%82%8B) <br>

+ `$ rails db:reset`を実行<br>

+ http://localhost:3000/users/sign_up にアクセスして、ユーザー登録して http://localhost:3000/users/1 にアクセスしてみる<br>

### ナビゲーションヘッダーにプロフィールページに飛ぶリンクを追加

+ [Rails deviseで使えるようになるヘルパーメソッド一覧](https://qiita.com/tobita0000/items/866de191635e6d74e392) <br>

+ `app/views/partial/_navbar.html.erb`を編集<br>

```html:_navbar.html.erb
<nav class="navbar navbar-expand-lg navbar-light">
  <div class="container">
    <%= link_to "", root_path, class: "navbar__brand navbar__mainLogo" %>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent"
      aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav  ml-md-auto align-items-center">
        <li>
          <%= link_to "投稿", "#", class: "btn btn-primary" %>
        </li>
        <li>
          <%= link_to "", user_path(current_user), class: "nav-link commonNavIcon profile-icon" %>
        </li>
      </ul>
    </div>
  </div>
</nav>
```

+ localhost:3000 にアクセスしてみる<br>

## 4-2 プロフィール編集機能の開発

### 1. プロフィール編集リンクの表示を限定

+ `app/views/users/show.html.erb`を編集<br>

```html:show.html.erb
<div class="profile-wrap">
  <div class="row">
    <div class="col-md-4 text-center">
      <%= image_tag avatar_url(@user), class: "round-img" %>
    </div>
    <div class="col-md-8">
      <div class="row">
        <h1><%= @user.name %></h1>

        <% if @user == current_user %> <!-- 追加 -->
        <%= link_to "プロフィールを編集", edit_user_registration_path, class: "btn btn-outline-dark common-btn edit-profile-btn" %>
        <button type="button" class="setting" data-toggle="modal" data-target="#exampleModal"></button>
        <% end %> <!-- 追加 -->

        <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
          aria-hidden="true">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">設定</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">X</span>
                </button>
              </div>
              <div class="list-group text-center">
                <%= link_to "サインアウト", destroy_user_session_path, method: :delete, class: "list-group-item list-group-item-action" %>
                <%= link_to "キャンセル", "#", class: "list-group-item list-group-item-action", "data-dismiss": "modal" %>
              </div>
            </div>
          </div>
        </div>
      </div>
      <% if @user == current_user %>
      <div class="row">
        <p>
          <%= @user.email %>
        </p>
      </div>
      <% end %>
    </div>
  </div>
</div>
```

### 2. registrationsコントローラを追加

+ [Devise でユーザーがパスワードなしでアカウント情報を変更するのを許可](https://easyramble.com/user-account-update-without-password-on-devise.html) <br>

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  # 編集
  devise_for :users,
    controllers: { registrations: 'registrations' }
  # ここまで

  root 'pages#home'

  get '/users/:id', to: 'users#show', as: 'user'
end
```

+ `$ rails g controller registrations_controller`を実行<br>

+ `app/controllers/registrations_controller.rb`を編集<br>

```rb:registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  protected

  def update_resource(resource, params)
    resource.update_without_current_password(params)
  end
end
```

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 50 }

  def update_without_current_password(params, *options)
    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update(params, *options)
    clean_up_passwords
    result
  end
end
```

※ これでパスワードを入力しなくてもプロフィールの情報を編集できるようになる。またパスワードも編集可能である。<br>

### 3. プロフィール編集ページの見た目を整える

+ `app/views/devise/registrations/edit.html.erb`を編集<br>

```html:edit.html.erb
<div class="col-md-offset-2 mb-4 edit-profile-wrapper">
  <div class="row">
    <div class="col-md-8 mx-auto">
      <div class="profile-form-wrap">
        <%= form_with scope: resource, as: resource_name, url: registration_path(resource_name), local: true, method: :patch do |f| %>
        <div class="form-group">
          <%= f.label :name, "名前" %>
          <%= f.text_field :name, autofocus: true, class: "form-control" %>
        </div>

        <div class="form-group">
          <%= f.label :email, "メールアドレス" %>
          <%= f.email_field :email, autofocus: true, class: "form-control" %>
        </div>

        <div class="form-group">
          <%= f.label :password, "パスワード" %>
          <%= f.email_field :password, autofocus: "off", class: "form-control" %>
        </div>

        <div class="form-group">
          <%= f.label :password_confirmation, "パスワードの確認" %>
          <%= f.email_field :password_confirmation, autofocus: "off", class: "form-control" %>
        </div>

        <%= f.submit "変更する", class: "btn btn-primary" %>
        <% end %>
      </div>
    </div>
  </div>
</div>
```

+ `app/javascript/stylesheets/application.scss`を編集<br>

```scss:application.scss
@import '~bootstrap/scss/bootstrap';
@import 'layouts/navbar';
@import 'common';
@import 'users/devise';
@import 'users/show';
@import 'users/edit'; // 追加
```

+ `$ touch app/javascript/stylesheets/users/edit.scss`を実行<br>

+ `app/javascript/stylesheets/users/edit.scss`を編集<br>

```scss:edit.scss
.profile-form-wrap {
  background: #fff;
  padding: 20px;
  border: 1px solid #e6e6e6;
}

.profile-form-wrap label {
  font-weight: bold;
}

.edit-profile-wrapper {
  margin-top: 60px;
}
```

+ http://localhost:3000/users/edit にアクセスしてみる<br>

### 4. プロフィール編集後のリダイレクト先を変更

+ `app/controllers/registrations_controller.rb`を編集<br>

```rb:registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  protected

  def update_resource(resource, params)
    resource.update_without_current_password(params)
  end

  # 追加
  def after_update_path_for(resource)
    user_path(resource)
  end
end
```

+ 編集が完了するとプロフィールページにリダイレクトするようになる<br>

+ [Method: Devise::RegistrationsController#after_update_path_for](https://www.rubydoc.info/github/plataformatec/devise/Devise%2FRegistrationsController:after_update_path_for) <br>
