# 7章: いいね機能

## 7-1 モデルの作成

### Likeモデルを作成

|カラム名|データ型|
|:---:|:---:|
|post|references|
|user|references|

+ `$ rails g model like`を実行<br>

+ `db/migrate/create_likes.rb`を編集<br>

```rb:create_likes.rb
class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.references :post, foregin_key: true, null: false
      t.references :user, foregin_key: true, null: false
      t.timestamps
    end
  end
end
```

+ `$ rails db:migrate`を実行<br>

### 2. アソシエーションの設定

+ [Active Record の関連付け (アソシエーション)](https://railsguides.jp/association_basics.html) <br>

### UserモデルとLikeモデルのアソシエーションの設定

```
ユーザーは複数のいいねをすることができる
とあるいいねAに関して、いいねAをしたユーザーは1人しかいない

UserモデルとLikeモデルは「1対多」の関係になる
```

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :likes # 追加

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

+ `app/models/like.rb`を編集<br>

```rb:like.rb
class Like < ApplicationRecord
  belongs_to :user # 追加
end
```

### PostモデルとLikeモデルのアソシエーション設定

```
一つの投稿は複数のいいねを持つことができる
いいねAに関して、いいねAに紐づく投稿は一つしかない

PostモデルとLikeモデルは「1対多」の関係になる
```

+ `app/models/post.rb`を編集<br>

```rb:post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy
  has_many :likes, -> { order(created_at: :desc) }, dependent: :destroy

  accepts_nested_attributes_for :photos
end
```

+ [Active Record の関連付け (アソシエーション) :dependent](https://railsguides.jp/association_basics.html#belongs-to%E3%81%AE%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3-dependent) <br>


+ `app/models/like.rb`を編集<br>

```rb:like.rb
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post # 追加
end
```

### 3. バリデーションの設定

+ `app/models/like.rb`を編集<br>

```rb:like.rb
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id } # 追加 user_idとpost_idの組み合わせが重複しないことを検証している
end
```

+ [Active Recordバリデーション uniqueness](https://railsguides.jp/active_record_validations.html#uniqueness) <br>

## 7-2 いいね機能の実装

### 1. ルーティングの追加

```
likesコントローラのcreateアクション。いいねの情報を保存するルーティング。
likesコントローラのdestroyアクション。いいねの情報を削除するルーティング。
```

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  devise_for :users,
    controllers: { registrations: 'registrations' }

  root 'posts#index'

  get '/users/:id', to: 'users#show', as: 'user'

  resources :posts, only: %i(new create index show destroy) do
    resources :photos, only: %i(create)
    resources :likes, only: %i(create destroy) # 追加
  end
end
```

```
post_likes POST   /posts/:post_id/likes(.:format)            likes#create
post_like  DELETE /posts/:post_id/likes/:id(.:format)        likes#destroy
```

### 2. コントローラの作成

+ `rails g controller likes`を実行<br>

### 3. 作成したコントローラにアクションを追加

+ `app/controllers/likes_controller.rb`を編集<br>

```rb:likes_controller.rb
class LikesController < ApplicationController
  def create
    @like = current_user.likes.build(like_params)
    @post = @like.post
    if @like.save
      respond_to :js
    end
  end

  private
  def like_params
    params.permit(:post_id)
  end
end
```

+ `app/controllers/likes_controller.rb`を編集<br>

```rb:likes_controller.rb
class LikesController < ApplicationController
  before_action :authenticate_user! # 追加

  def create
    @like = current_user.likes.build(like_params)
    @post = @like.post
    if @like.save
      redirect_back fallback_location: root_path
    end
  end

  # 追加
  def destroy
    @like = Like.find_by(id: params[:id])
    @post = @like.post
    if @like.destroy
      redirect_back fallback_location: root_path
    end
  end
  # ここまで

  private
  def like_params
    params.permit(:post_id)
  end
end
```

### 4. ビューを作成

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

        <% if post.user_id == current_user.id %>
        <%= link_to post_path(post), method: :delete, class: "ml-auto mx-0 my-auto" do %>
        <div class="delete-post-icon">
        </div>
        <% end %>
        <% end %>
      </div>

      <%= link_to(post_path(post)) do %>
      <%= image_tag post.photos.first.image.url(:medium), class: "card-img-top" %>
      <% end %>

      <div class="card-body">
        <div class="row parts">
          <!-- 編集 -->
          <div id="like-icon-post-<%= post.id.to_s %>">
            <% if post.liked_by(current_user).present? %>
            <%= link_to "いいねを取り消す", post_like_path(post.id, post.liked_by(current_user)), method: :DELETE, remote: true, class: "loved hide-text" %>
            <% else %>
            <%= link_to "いいね", post_likes_path(post), method: :POST, remote: true, class: "love hide-text" %>
            <% end %>
          </div>
          <!-- ここまで -->
          <%= link_to "", "#", class: "comment" %>
        </div>
        <!-- 編集 -->
        <div id="like-text-post-<%= post.id.to_s %>">
          <%= render "like_text", { likes: post.likes } %>
        </div>
        <!-- ここまで -->
        <div>
          <span><strong><%= post.user.name %></strong></span>
          <span><%= post.caption %></span>
          <%= link_to time_ago_in_words(post.created_at).upcase + "前", post_path(post), class: "post-time no-text-decoration" %>
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

+ `app/models/post.rb`を編集<br>

```rb:post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy
  has_many :likes, -> { order(created_at: :desc) }, dependent: :destroy

  accepts_nested_attributes_for :photos

  # 追加
  def liked_by(user)
    # user_idとpost_idが一致するlikeを検索する 一致しなければnilを返す
    Like.find_by(user_id: user.id, post_id: id)
  end
  # ここまで
end
```

+ `$ touch app/views/posts/_like_text.html.erb`を実行<br>

```html:_like_text.html.erb
<strong>
  <% likes.each.with_index do |like, index| %>
  <% if likes.size == 1 %>
  <%= like.user.name %></strong> が「いいね！」しました
<% elsif like == likes.last %>
</strong>and<strong>
  <%= + like.user.name %></strong> が「いいね！」しました
<% elseif index > 1 %>
</strong><%= "and" + (likes.size-index).to_s + " 他 " %>が「いいね！」しました
<% break %>
<% elsif index == likes.size-2 || index == 1 %>
<%= like.user.name %>
<% else %>
<%= like.user.name + ", " %>
<% end %>
<% end %>
</strong>
```

+ `app/javascript/stylesheets/post.scss`を編集<br>

```scss:post.scss
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

.post-wrap .col-md-8 {
  padding: 0px;
}

.card-right {
  padding: 20px;
}

.card-right-name {
  padding-bottom: 10px;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
}

.card-right-comment {
  padding-bottom: 10px;
  border-bottom: 1px solid #e6e6e6;
  height: 320px;
  overflow: auto;
}

.postShow-wrap {
  border: 1px solid #e6e6e6;
  margin: 40px;
}

.post-user-name {
  display: flex;
  align-items: center;
  line-height: 0;
}

.delete-post-icon {
  background-image: url('~parts9');
  background-repeat: no-repeat;
  width: 20px;
  height: 20px;
  background-size: 20px !important;
  color: #262626;
  font-size: 20px;
}

.loved {
  background-image: url('~parts7');
  background-repeat: no-repeat;
  height: 36px;
  width: 36px;
  background-size: 36px !important;
}

.hide-text {
  display: block;
  overflow: hidden;
  text-indent: 110%;
  white-space: nowrap;
}
```

+ `$ touch app/views/likes/create.js.erb`を実行<br>

+ `app/views/likes/create.js.erb`を編集<br>

```js:create.js.erb
$('#like-icon-post-<%= @post.id.to_s %>').
  html('<%= link_to "いいねを取り消す", post_like_path(@post.id, @like), method: :DELETE, remote: true, class: "loved hide-text" %>');
$('#like-text-post-<%= @post.id.to_s %>').
  html('<%= j render "posts/like_text", { likes: @post.likes } %>');
```

+ `$ touch app/views/likes/destroy.js.erb`を実行<br>

+ `app/views/likes/destroy.js.erb`を編集<br>

```js:destroy.js.erb
$('#like-icon-post-<%= @post.id.to_s %>').
  html('<%= link_to "いいね", post_likes_path(@post), method: :POST, remote: true, class: "love hide-text" %>');
$('#like-text-post-<%= @post.id.to_s %>').
  html('<%= j render "posts/like_text", { likes: @post.likes } %>');
```