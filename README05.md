## 5-4 投稿一覧ページの作成

### 1. ルーティングの設定

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  devise_for :users,
    controllers: { registrations: 'registrations' }

  root 'pages#home'

  get '/users/:id', to: 'users#show', as: 'user'

  resources :posts, only: %i(new create index) do # 編集
    resources :photos, only: %i(create)
  end
end
```

```
post_photos POST   /posts/:post_id/photos(.:format)    photos#create
posts       GET    /posts(.:format)                    posts#index
            POST   /posts(.:format)                    posts#create
new_post    GET    /posts/new(.:format)                posts#new
```

### 2. コントローラの編集

+ `app/controllers/posts_controller.rb`を編集<br>

```rb:posts_controller.rb
class PostsController < ApplicationController
  before_action :authenticate_user!

  def new
    @post = Post.new
    @post.photos.build
  end

  def create
    @post = Post.new(post_params)
    if @post.photos.present?
      @post.save
      redirect_to root_path
      flash[:notice] = "投稿が保存されました"
    else
      redirect_to root_path
      flash[:alert] = "投稿に失敗しました"
    end
  end

  # 追加
  def index
    @post = Post.limit(10).order('created_at DESC')
  end
  # ここまで

  private
  def post_params
    params.require(:post).permit(:caption, photos_attributes: [:image]).merge(user_id: current_user.id)
  end
end
```

### N+1問題

+ [Active Record クエリインターフェイス 関連付けを一括読み込みする](https://railsguides.jp/active_record_querying.html#%E9%96%A2%E9%80%A3%E4%BB%98%E3%81%91%E3%82%92%E4%B8%80%E6%8B%AC%E8%AA%AD%E3%81%BF%E8%BE%BC%E3%81%BF%E3%81%99%E3%82%8B) <br>

+ `app/controllers/posts_controller.rb`を編集<br>

```rb:posts_controller.rb
class PostsController < ApplicationController
  before_action :authenticate_user!

  def new
    @post = Post.new
    @post.photos.build
  end

  def create
    @post = Post.new(post_params)
    if @post.photos.present?
      @post.save
      redirect_to root_path
      flash[:notice] = "投稿が保存されました"
    else
      redirect_to root_path
      flash[:alert] = "投稿に失敗しました"
    end
  end

  def index
    @posts = Post.limit(10).includes(:photos, :user).order('created_at DESC') # 編集
  end

  private
  def post_params
    params.require(:post).permit(:caption, photos_attributes: [:image]).merge(user_id: current_user.id)
  end
end
```

### 3. ビューを作成

+ `$ touch app/views/posts/index.html.erb`を実行<br>

+ `app/views/posts/index.html.erb`を編集<br>

```html:index.html.erb
<% @posts.each do |post| %>
<p><%= post.caption %></p>
<%= image_tag post.photos.first.image.url(:medium) %>
<% end %>
```

+ [carrierwave Adding versions](https://github.com/carrierwaveuploader/carrierwave#adding-versions) <br>

+ http://localhost:3000/posts にアクセスしてみる<br>

+ `app/views/posts/index.html.erb`を編集<br>

```html:index.html.erb
<% @posts.each do |post| %>
<div class="col-md-8 col-md-2 mx-auto">
  <div class="card-wrap">
    <div class="card">
      <div class="card-header align-items-center d-flex">
        <%= link_to user_path(post.user), class: "no-text-decoration" do %>
        <%= image_tag avatar_url(post.user), class: "post-profile-icon" %>
        <% end %>
        <%= link_to user_path(post.user), class: "black-color no-text-decoration",
            title: post.user.name do %>
        <strong><%= post.user.name %></strong>
        <% end %>
      </div>

      <%= image_tag post.photos.first.image.url(:medium), class: "card-img-top" %>

      <div class="card-body">
        <div class="row parts">
          <%= link_to "", "#", class: "love" %>
          <%= link_to "", "#", class: "comment" %>
        </div>
        <div><strong>「いいね！」10件</strong></div>
        <div>
          <span><strong><%= post.user.name %></strong></span>
          <span><%= post.caption %></span>
          <%= link_to time_ago_in_words(post.created_at).upcase + "前", "#", class: "post-time no-text-decoration" %>
          <hr>
          <div class="row parts">
            <form action="#" class="w-100">
              <div>
                <textarea class="form-control comment-input border-0" placeholder="コメント..." rows="1"></textarea>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<% end %>
```

+ `app/javascript/stylesheets/application.scss`を編集<br>

```scss:application.scss
@import '~bootstrap/scss/bootstrap';
@import 'layouts/navbar';
@import 'common';
@import 'users/devise';
@import 'users/show';
@import 'users/edit';
@import 'posts'; // 追加
```

+ `$ touch app/javascript/stylesheets/posts.scss`を実行<br>

+ `app/javascript/stylesheets/posts.scss`を編集<br>

```scss:posts.scss
.post-profile-icon {
  height: 40px;
  width: 40px;
  border-radius: 50%;
  margin-right: 10px;
}

.card-wrap {
  margin: 40px 0px;
}

.no-text-decoration:hover {
  text-decoration: none;
}

.black-color {
  color: #262626;
}

.parts {
  margin: 12px 0;
}

.love {
  background-image: url('~parts5');
  background-repeat: no-repeat;
  height: 36px;
  width: 36px;
  background-size: 36px !important;
}

.comment {
  margin-left: 8px;
  background-image: url('~parts6');
  background-repeat: no-repeat;
  height: 36px;
  width: 36px;
  background-size: 40px !important;
}

.post-time {
  margin: 0;
  color: #999;
  font-size: 10px;
}

.post-sub-text {
  text-decoration: none;
  color: #262626;
}
```

+ `localhost:3000/posts`にアクセスしてみる<br>

### 更新時間を日本語にする

+ `config/application.rb`を編集<br>

```rb:application.rb
require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.i18n.default_locale = :ja # 追加

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
```

+ `$ config/locales/ja.yml`を実行<br>

+ `config/locales/ja.yml`を編集<br>

```yml:ja.yml
ja:
  datetime:
    distance_in_words:
      half_a_minute: "30秒前後"
      less_than_x_seconds:
        one: "1秒"
        other: "%{count}秒"
      x_seconds:
        one: "1秒"
        other: "%{count}秒"
      less_than_x_minutes:
        one: "1分"
        other: "%{count}分"
      x_minutes:
        one: "約1分"
        other: "%{count}分"
      about_x_hours:
        one: "約1時間"
        other: "約%{count}時間"
      x_days:
        one: "1日"
        other: "%{count}日"
      about_x_months:
        one: "約1ヶ月"
        other: "約%{count}ヶ月"
      x_months:
        one: "1ヶ月"
        other: "%{count}ヶ月"
      almost_x_years:
        one: "１年弱"
        other: "%{count}年弱"
      about_x_years:
        one: "約1年"
        other: "約%{count}年"
      over_x_years:
        one: "1年以上"
        other: "%{count}年以上"

  devise:
    confirmations:
      confirmed: "アカウントを登録しました。"
      send_instructions: "アカウントの有効化について数分以内にメールでご連絡します。"
      send_paranoid_instructions: "あなたのメールアドレスが登録済みの場合、本人確認用のメールが数分以内に送信されます。"
    failure:
      already_authenticated: "すでにサインインしています。"
      inactive: "アカウントが有効化されていません。メールに記載された手順にしたがって、アカウントを有効化してください。"
      invalid: "%{authentication_keys} もしくはパスワードが不正です。"
      locked: "あなたのアカウントは凍結されています。"
      last_attempt: "あなたのアカウントが凍結される前に、複数回の操作がおこなわれています。"
      not_found_in_database: "%{authentication_keys} もしくはパスワードが不正です。"
      timeout: "セッションがタイムアウトしました。もう一度サインインしてください。"
      unauthenticated: "アカウント登録もしくはサインインしてください。"
      unconfirmed: "メールアドレスの本人確認が必要です。"
    mailer:
      confirmation_instructions:
        subject: "アカウントの有効化について"
      reset_password_instructions:
        subject: "パスワードの再設定について"
      unlock_instructions:
        subject: "アカウントの凍結解除について"
      password_change:
        subject: "パスワードの変更について"
    omniauth_callbacks:
      failure: "%{kind} アカウントによる認証に失敗しました。理由：（%{reason}）"
      success: "%{kind} アカウントによる認証に成功しました。"
    passwords:
      no_token: "このページにはアクセスできません。パスワード再設定メールのリンクからアクセスされた場合には、URL をご確認ください。"
      send_instructions: "パスワードの再設定について数分以内にメールでご連絡いたします。"
      send_paranoid_instructions: "あなたのメールアドレスが登録済みの場合、パスワード再設定用のメールが数分以内に送信されます。"
      updated: "パスワードが正しく変更されました。"
      updated_not_active: "パスワードが正しく変更されました。"
    registrations:
      destroyed: "アカウントを削除しました。またのご利用をお待ちしております。"
      signed_up: "アカウント登録が完了しました。"
      signed_up_but_inactive: "サインインするためには、アカウントを有効化してください。"
      signed_up_but_locked: "アカウントが凍結されているためサインインできません。"
      signed_up_but_unconfirmed: "本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。"
      update_needs_confirmation: "アカウント情報を変更しました。変更されたメールアドレスの本人確認のため、本人確認用メールより確認処理をおこなってください。"
      updated: "アカウント情報を変更しました。"
    sessions:
      signed_in: "サインインしました。"
      signed_out: "サインアウトしました。"
      already_signed_out: "既にサインアウト済みです。"
    unlocks:
      send_instructions: "アカウントの凍結解除方法を数分以内にメールでご連絡します。"
      send_paranoid_instructions: "アカウントが見つかった場合、アカウントの凍結解除方法を数分以内にメールでご連絡します。"
      unlocked: "アカウントを凍結解除しました。"
  errors:
    messages:
      already_confirmed: "は既に登録済みです。サインインしてください。"
      confirmation_period_expired: "の期限が切れました。%{period} までに確認する必要があります。 新しくリクエストしてください。"
      expired: "の有効期限が切れました。新しくリクエストしてください。"
      not_found: "は見つかりませんでした。"
      not_locked: "は凍結されていません。"
      not_saved:
        one: "エラーが発生したため %{resource} は保存されませんでした:"
        other: "%{count} 件のエラーが発生したため %{resource} は保存されませんでした:"
```

+ サーバー再起動して localhost:3000/posts にアクセスしてみる<br>

+ [i18nについて](https://morizyun.github.io/ruby/rails-function-i18n-internationalization.html) <br>

+ [Rails国際化（I18n）API](https://railsguides.jp/i18n.html) <br>


### rootルーティングの編集<br>

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  devise_for :users,
    controllers: { registrations: 'registrations' }

  root 'posts#index' # 編集

  get '/users/:id', to: 'users#show', as: 'user'

  resources :posts, only: %i(new create index) do
    resources :photos, only: %i(create)
  end
end
```

+ localhost:3000/posts にアクセスしてみる<br>
