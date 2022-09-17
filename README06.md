## 5-5 投稿ページの見た目を整える

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
          <%= link_to "投稿", new_post_path, class: "btn btn-primary" %> <!-- 編集 -->
        </li>
        <li>
          <%= link_to "", user_path(current_user), class: "nav-link commonNavIcon profile-icon" %>
        </li>
      </ul>
    </div>
  </div>
</nav>
```

### 2. ビューを編集

+ `app/views/posts/new.html.erb`を編集<br>

```html:new.html.erb
<div class="d-flex flex-column align-items-center mt-3">
  <div class="col-xl-7 col-lg-8 col-md-10 col-sm-11 post-card">
    <div class="card">
      <div class="card-header">
        投稿画面
      </div>
      <div class="card-body">
        <%= form_with model: @post, class: "upload-images p-0 border-0" do |f| %>
        <div class="form-group row mt-2">
          <div class="col-auto pr-0">
            <%= image_tag avatar_url(current_user), class: "post-profile-icon" %>
          </div>
          <div class="col pl-0">
            <%= f.text_field :caption, class: "form-control border-0", placeholder: "キャプションを書く" %>
          </div>
        </div>
        <div class="mb-3">
          <%= f.fields_for :photos do |i| %>
          <%= i.file_field :image %>
          <% end %>
        </div>
        <%= f.submit "投稿する", class: "btn btn-primary" %>
        <% end %>
      </div>
    </div>
  </div>
</div>
```

# 6章: 投稿機能の詳細・削除機能

## 6-1 投稿の詳細ページの作成

### 1. ルーティングの設定

+ `config/routes.rb

```rb:routes.rb
Rails.application.routes.draw do
  devise_for :users,
    controllers: { registrations: 'registrations' }

  root 'posts#index'

  get '/users/:id', to: 'users#show', as: 'user'

  resources :posts, only: %i(new create index show) do # 編集
    resources :photos, only: %i(create)
  end
end
```

```
post GET   /posts/:id(.:format)    posts#show
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

  def index
    @posts = Post.limit(10).includes(:photos, :user).order('created_at DESC')
  end

  # 追加
  def show
    @post = Post.find_by(id: params[:id])
  end
  # ここまで

  private
  def post_params
    params.require(:post).permit(:caption, photos_attributes: [:image]).merge(user_id: current_user.id)
  end
end
```

### 3. ビューを作成・編集

+ `$ touch app/views/posts/show.html.erb`を実行<br>

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
            </div>
          </div>
        </div>
        <div class="row parts">
        </div>
        <div class="post-time"><%= time_ago_in_words(@post.created_at).upcase %>前</div>
        <hr>
      </div>
    </div>
  </div>
</div>
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

// 追加
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
// ここまで
```
### 投稿詳細ページに遷移するリンクを追加

```
post GET /posts/:id(.:format) posts#show
```

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

      <%= link_to(post_path(post)) do %> <!-- 追加 @postsを each で１つずつ順に取り出した post という変数を引数に渡す -->
      <%= image_tag post.photos.first.image.url(:medium), class: "card-img-top" %>
      <% end %> <!-- 追加 -->

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

      <%= link_to(post_path(post)) do %>
      <%= image_tag post.photos.first.image.url(:medium), class: "card-img-top" %>
      <% end %>

      <div class="card-body">
        <div class="row parts">
          <%= link_to "", "#", class: "love" %>
          <%= link_to "", "#", class: "comment" %>
        </div>
        <div><strong>「いいね！」10件</strong></div>
        <div>
          <span><strong><%= post.user.name %></strong></span>
          <span><%= post.caption %></span>
          <%= link_to time_ago_in_words(post.created_at).upcase + "前", post_path(post), class: "post-time no-text-decoration" %> <!-- 編集 -->
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

### 6-2 投稿の削除機能

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  devise_for :users,
    controllers: { registrations: 'registrations' }

  root 'posts#index'

  get '/users/:id', to: 'users#show', as: 'user'

  resources :posts, only: %i(new create index show destroy) do # 編集
    resources :photos, only: %i(create)
  end
end
```

```
post GET    /posts/:id(.:format)          posts#show
     DELETE /posts/:id(.:format)          posts#destroy
```

### 2. コントローラの編集

+ `app/controlers/posts_controller.rb`を編集<br>

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
    @posts = Post.limit(10).includes(:photos, :user).order('created_at DESC')
  end

  def show
    @post = Post.find_by(id: params[:id])
  end

  # 追加
  def destroy
    @post = Post.find_by(id: params[:id])
    if @post.user == current_user
      flash[:notice] = "投稿が削除されました" if @post.destroy
    else
      flash[:alert] = "投稿の削除に失敗しました"
    end
    redirect_to root_path
  end
  # ここまで

  private
  def post_params
    params.require(:post).permit(:caption, photos_attributes: [:image]).merge(user_id: current_user.id)
  end
end
```

### リファクタリング

+ `app/controlers/posts_controller.rb`を編集<br>

```rb:posts_controller.rb
class PostsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_post, only: %i(show destroy) # 追加

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
    @posts = Post.limit(10).includes(:photos, :user).order('created_at DESC')
  end

  def show
    # @post = Post.find_by(id: params[:id]) 削除
  end

  def destroy
    # @post = Post.find_by(id: params[:id]) 削除
    if @post.user == current_user
      flash[:notice] = "投稿が削除されました" if @post.destroy
    else
      flash[:alert] = "投稿の削除に失敗しました"
    end
    redirect_to root_path
  end

  private
  def post_params
    params.require(:post).permit(:caption, photos_attributes: [:image]).merge(user_id: current_user.id)
  end

  # 追加
  def set_post
    @post = Post.find_by(id: params[:id])
  end
  # ここまで
end
```

### 3. ビューを編集

`post DELETE /posts/:id(.:format) posts#destroy`<br>

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

        <!-- 追加 -->
        <% if post.user_id == current_user.id %>
        <%= link_to post_path(post), method: :delete, class: "ml-auto mx-0 my-auto" do %>
        <div class="delete-post-icon">
        </div>
        <% end %>
        <% end %>
        <!-- ここまで -->
      </div>

      <%= link_to(post_path(post)) do %>
      <%= image_tag post.photos.first.image.url(:medium), class: "card-img-top" %>
      <% end %>

      <div class="card-body">
        <div class="row parts">
          <%= link_to "", "#", class: "love" %>
          <%= link_to "", "#", class: "comment" %>
        </div>
        <div><strong>「いいね！」10件</strong></div>
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

// 追加
.delete-post-icon {
  background-image: url('~parts9');
  background-repeat: no-repeat;
  width: 20px;
  height: 20px;
  background-size: 20px !important;
  color: #262626;
  font-size: 20px;
}
// ここまで
```
