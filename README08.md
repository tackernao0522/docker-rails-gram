# 8-1 モデルの作成

## 1. モデルの作成

```
コメントの内容
どの投稿にコメントをしたか投稿の情報
誰がコメントしたかユーザーの情報
```

### Commentモデルの作成

|カラム名|データ型|
|:---:|:---:|
|comment|text|
|post|references|
|user|references|

+ `$ rails g model comment`を実行<br>

+ `db/migrate/create_comment.rb`を編集<br>

```rb:create_comment.rb
class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :comment, null: false
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

### UserモデルとCommentモデルのアソシエーションの設定

```
ユーザーは複数のコメントをすることができる
コメントAに関して、コメントAをしたユーザーは一人しかしない

UserモデルとCommentモデルは「1対多」の関係になる
```

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :likes
  has_many :comments # 追加

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

+ `app/models/comment.rb`を編集<br>

```rb:comment.rb
class Comment < ApplicationRecord
  belongs_to :user
end
```

### PostモデルとCommentモデルのアソシエーションの設定

```
一つの投稿は複数のコメントを持つことができる
コメントAに関して、コメントAに紐づく投稿は一つしかない

PostモデルとCommentモデルは「1対多」の関係になります。
```

+ `app/models/post.rb`を編集<br>

```rb:post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy
  has_many :likes, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :comments, dependent: :destroy # 追加

  accepts_nested_attributes_for :photos

  def liked_by(user)
    # user_idとpost_idが一致するlikeを検索する
    Like.find_by(user_id: user.id, post_id: id)
  end
end
```

+ [Active Record の関連付け (アソシエーション) :dependent](https://railsguides.jp/association_basics.html#belongs-to%E3%81%AE%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3-dependent) <br>

+ `app/models/comment.rb`を編集<br>

```rb:comment.rb
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post # 追加
end
```

## 8-2 コメント機能の実装

### 1. ルーティングの追加

```
commentsコントローラーのcreateアクション。コメントの情報を保存するルーティング。
commentsコントローラーのdestoryアクション。コメントの情報を削除するルーティング。
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
    resources :likes, only: %i(create destroy)
    resources :comments, only: %i(create destroy) # 追加
  end
end
```

```
post_comments POST   /posts/:post_id/comments(.:format)      comments#create
post_comment  DELETE /posts/:post_id/comments/:id(.:format)  comments#destroy
```

### 2. コントローラの作成

+ `$ rails g controller comments`を実行<br>

+ `app/controllers/comments_controller.rb`を編集<br>

### 3. 作成したコントローラにアクションを追加

```rb:comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment = Comment.new(comment_params)
    @post = @comment.post
    if @comment.save
      respond_to :js
    else
      flash[:alert] = "コメントに失敗しました"
    end
  end

  def destroy
    @comment = Comment.find_by(id: params[:id])
    @post = @comment.post
    if @comment.destroy
      respond_to :js
    else
      flash[:alert] = "コメントの削除に失敗しました"
    end
  end

  private

  def comment_params
    params.required(:comment).permit(:user_id, :post_id, :comment)
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
          <div id="like-icon-post-<%= post.id.to_s %>">
            <% if post.liked_by(current_user).present? %>
            <%= link_to "いいねを取り消す", post_like_path(post.id, post.liked_by(current_user)), method: :DELETE, remote: true, class: "loved hide-text" %>
            <% else %>
            <%= link_to "いいね", post_likes_path(post), method: :POST, remote: true, class: "love hide-text" %>
            <% end %>
          </div>
          <%= link_to "", "#", class: "comment" %>
        </div>
        <div id="like-text-post-<%= post.id.to_s %>">
          <%= render "like_text", { likes: post.likes } %>
        </div>
        <div>
          <span><strong><%= post.user.name %></strong></span>
          <span><%= post.caption %></span>
          <%= link_to time_ago_in_words(post.created_at).upcase + "前", post_path(post), class: "post-time no-text-decoration" %>
          <!-- 編集 -->
          <div id="comment-post-<%= post.id.to_s %>">
            <%= render 'comment_list', { post: post } %>
          </div>
          <%= link_to time_ago_in_words(post.created_at).upcase + "前", post_path, class: "light-color post-time no-text-decoration" %>
          <hr>
          <div class="row actions" id="comment-form-post-<%= post.id.to_s %>">
            <%= form_with model: [post, Comment.new], local: false, class: "w-100" do |f| %>
            <%= f.hidden_field :user_id, value: current_user.id %>
            <%= f.hidden_field :post_id, value: post.id %>
            <%= f.text_field :comment, class: "form-control comment-input border-0", placeholder: "コメント...", autocomplete: :off %>
            <% end %>
          </div>
          <!-- ここまで -->
        </div>
      </div>
    </div>
  </div>
</div>
<% end %>
```

+ `touch app/views/posts/_comment_list.html.erb`を実行<br>

+ `app/views/posts/_comment_list.html.erb`を編集<br>

```html:_comment_list.html.erb
<% post.comments.each do |comment| %>
<div class="mb-2">
  <% if comment.user == current_user %>
  <%= link_to "", post_comment_path(post.id, comment), method: :delete, remote: true, class: "delete-comment" %>
  <% end %>
  <span>
    <strong>
      <%= link_to comment.user.name, user_path(comment.user), class: "no-text-decoration black-color" %>
    </strong>
  </span>
  <span><%= comment.comment %></span>
</div>
<% end %>
```

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

// 追加
.delete-comment {
  background-image: url('~parts8');
  background-repeat: no-repeat;
  width: 11px;
  height: 11px;
  float: right;
  margin: 5px 0 0 10px;
  background-size: 11px !important;
}
```

+ `touch app/views/comments/create.js.erb`を実行<br>

+ `app/views/comments/create.js.erb`を編集<br>

```js:create.js.erb
$('#comment-post-<%= @post.id.to_s %>').
html('<%= j render "posts/comment_list", { post: @post } %>');
$('#comment-form-post-<%= @post.id.to_s %> #comment_comment').val("");
```

+ `touch app/views/comments/destroy.js.erb`を実行<br>

+ `app/views/comments/destroy.js.erb`を編集<br>

```js:destroy.js.erb
$('#comment-post-<%= @post.id.to_s %>').
html('<%= j render "posts/comment_list", { post: @post } %>');
```

### 投稿詳細ページのビューを編集

+ `app/views/posts/show.html.erb`を編集<br>

```html:show.html.erb
<div class="col-md-10 col-md-offset-1 mx-auto postShow-wrap">
  <div class="row post-wrap">
    <div class="col-md-8">
      <div class="card-left">
        <%= image_tag @post.photos.first.image.url(:medium), class: "card-img-top" %>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card-right">
        <div class="card-right-comment">
          <div class="card-right-name">
            <%= link_to user_path(@post.user), class: "no-text-decoration" do %>
            <%= image_tag avatar_url(@post.user), class: "post-profile-icon" %>
            <% end %>
            <%= link_to user_path(@post.user), class: "black-color no-text-decoration post-user-name", title: @post.user.name do %>
            <strong><%= @post.user.name %></strong>
            <% end %>
          </div>
          <div class="m-2">
            <strong>
              <%= @post.caption %>
            </strong>
          </div>
          <div class="comment-post-id">
            <div class="m-2">
              <!-- 追加 -->
              <div id="comment-post-<%= @post.id.to_s %>">
                <%= render 'comment_list', post: @post %>
              </div>
              <!-- ここまで -->
            </div>
          </div>
        </div>
        <!-- 追加 -->
        <div class="row parts">
          <div id="like-icon-post-<%= @post.id.to_s %>">
            <% if @post.liked_by(current_user).present? %>
            <%= link_to "いいねを取り消す", post_like_path(@post.id, @post.liked_by(current_user)), method: :DELETE, remote: true, class: "loved hide-text" %>
            <% else %>
            <%= link_to "いいね", post_likes_path(@post), method: :POST, remote: true, class: "love hide-text" %>
            <% end %>
          </div>
        </div>

        <div id="like-text-post-<%= @post.id.to_s %>">
          <%= render "like_text", { likes: @post.likes } %>
        </div>

        <div class="post-time"><%= time_ago_in_words(@post.created_at).upcase %>前</div>
        <hr>

        <div class="row parts" id="comment-form-post-<%= @post.id.to_s %>">
          <%= form_with model: [@post, Comment.new], local: false, class: "w-100" do |f| %>
          <%= f.hidden_field :user_id, value: current_user.id %>
          <%= f.hidden_field :post_id, value: @post.id %>
          <%= f.text_field :comment, class: "form-control comment-input border-0", placeholder: "コメント...", autocomplete: :off %>
          <% end %>
        </div>
        <!-- ここまで -->

      </div>
    </div>
  </div>
</div>
```
