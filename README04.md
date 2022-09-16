# 5章 投稿機能

## 5-1 モデルの作成

### 1. モデルの作成

### Postモデルを作成

|カラム名|データ型|
|:---:|:---:|
|caption|string|
|user|references|

+ references型で保存すると、user_idを外部キーとして明示的に指定できる<br>

+ `$ rails g model post`を実行<br>

+ `db/migrate/create_posts.rb`を編集<br>

```rb:create_posts.rb
class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :caption # 追加
      t.references :user, foregin_key: true, null: false # 追加
      t.timestamps
    end
  end
end
```

+ `$ rails db:migrate`を実行<br>

### Photoモデルを作成

|カラム名|データ型|
|:---:|:---:|
|image|string|
|post|references|

+ `$ rails g model photo`を実行<br>

+ `db/migrate/create_photos.rb`を編集<br>

```rb:create_photos.rb
class CreatePhotos < ActiveRecord::Migration[6.1]
  def change
    create_table :photos do |t|
      t.string :image, null: false # 追加
      t.references :post, foregin_key: true, null: false # 追加
      t.timestamps
    end
  end
end
```

+ `$ rails db:migrate`を実行<br>

### 2. アソシエーションの設定

+ [Active Record の関連付け (アソシエーション)](https://railsguides.jp/association_basics.html) <br>

### UserモデルとPostモデルのアソシエーションの設定

```
ユーザーは複数の投稿をすることができる
投稿Aに関して、投稿Aを投稿したユーザーは1人しかいない

1対多の関係になる
```

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  has_many :posts, dependent: :destroy # 追加

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

+ `dependent: :destroy`をつけることで、オブジェクトが削除されるときに、関連付けられたオブジェクトのdestroyメソッドが実行される。<br>
この場合、ユーザーが削除されたら、そのユーザーに紐づく投稿も削除される。<br>

+ [Active Record の関連付け (アソシエーション) :dependent](https://railsguides.jp/association_basics.html#belongs-to%E3%81%AE%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3-dependent) <br>

+ `app/models/post.rb`を編集<br>

```rb:post.rb
class Post < ApplicationRecord
  belongs_to :user # 追加
end
```

### PostモデルとPhotoモデルのアソシエーション設定

```
一つの投稿は複数の写真を持つことができる
写真Aに関して、写真Aに紐づく投稿は一つしかない

PostモデルとPhotoモデルは 「1対多」の関係になる。
```

+ `app/meodels/post.rb`を編集<br>

```rb:post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy # 追加
end
```

+ `app/models/photo.rb`を編集<br>

```rb:photo.rb
class Photo < ApplicationRecord
  belongs_to :post # 追加
end
```

### 3. バリデーションの設定

+ `app/models/photo.rb`を編集<br>

```rb:photo.rb
class Photo < ApplicationRecord
  belongs_to :post

  validates :image, presence: true # 追加
end
```

## 5-2 carrierwave と MiniMagickの導入

### 1. carrierwaveの導入

+ [carrierwaveの公式ドキュメント](https://github.com/carrierwaveuploader/carrierwave) <br>

### carrierwaveのGemをインストール

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
gem 'devise'
gem 'carrierwave', '~> 2.0' # 追加
```

+ `$ bundle install`を実行<br>

### CarrierWaveのアップローダーを作成

+ `rails g uploader image`を実行<br>

+ `app/models/photo.rb`を編集<br>

```rb:photo.rb
class Photo < ApplicationRecord
  belongs_to :post

  validates :image, presence: true

  mount_uploader :image, ImageUploader # 追加
end
```

### imagemagickをインストール

+ `Dockerfileで既にインストール済み<br>

### MiniMagickのGemをインストール

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
gem 'devise'
gem 'carrierwave', '~> 2.0'
gem 'mini_magick' # 追加
```

+ `$ bundle install`を実行<br>

+ `app/uploaders/image_uploader.rb`を編集<br>

```rb:image_uploader.rb
class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick # コメントアウト解除

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # 追加
  version :medium do
    process resize_to_fill: [1080, 1080]
  end
  # ここまで

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # コメントアウト解除
  def extension_allowlist
    %w(jpg jpeg gif png)
  end
  # ここまで

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
```

## 5-3 投稿機能の実装

### 1. ルーティングの追加

```
postsコントローラのnewアクション。投稿ページを表示するルーティング。
postsコントローラのcreateアクション。投稿を作成るすルーティング。
photosコントローラのcreateアクション。投稿の写真を保存するルーティング。
```

+ `config/routes.rb`を編集<br>

```rb:routes.rb

```

```
  posts_new   GET     /posts/new(.:format)                posts#new
  posts       POST    /posts(.:format)                    posts#create
  post_photos POST    /posts/:post_id/photos(.:format)    photos#create
```

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  devise_for :users,
    controllers: { registrations: 'registrations' }

  root 'pages#home'

  get '/users/:id', to: 'users#show', as: 'user'

  # 編集
  resources :posts, only: %i(new create) do
    resources :photos, only: %i(create)
  end
  # ここまで
end
```

```
post_photos   POST   /posts/:post_id/photos(.:format)       photos#create
posts         POST   /posts(.:format)                       posts#create
new_post      GET    /posts/new(.:format)                   posts#new
```

### 2. コントローラの作成

+ `$ rails g controller posts`を実行<br>

+ `app/controllers/posts_controller.rb`を編集<br>

```rb:posts_controller.rb
class PostsController < ApplicationController

  def new
    @post = Post.new
    @post.photos.build
  end
end
```

+ `build` も `new` と同じくインスタンスを作成するメソッドである。 `build` と `new` に違いはない。<br>

+ Railsの監修でモデルを関連付け（今回で言うと、PostモデルとPhotoモデルの関連付け）したときに `build`を使う<br>

+ `app/controllers/posts_controller.rb`を編集<br>

```rb:posts_controller.rb
class PostsController < ApplicationController

  def new
    @post = Post.new
    @post.photos.build
  end

  # 追加
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

  private
  def post_params
    params.require(:post).permit(:caption, photos_attributes: [:image]).merge(user_id: current_user.id)
  end
  # ここまで
end
```

+ [[Ruby] privateメソッドの本質とそれを理解するメリット](https://qiita.com/kidach1/items/055021ce42fe2a49fd66) <br>

### accepts_nested_attributes_for

+ `accepts_nested_attributes_for`は、親子関係のある関連モデル(今回で言うとPostモデルとPhotoモデル)で、親から子を作成したり保存するときに使えます。<br.

+ `app/models/post.rb`を編集<br>

```rb:post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy

  accepts_nested_attributes_for :photos # 追加
end
```

### 4. ビューを作成

+ `$ touch app/views/posts/new.html.erb`を実行<br>

+ `app/views/posts/new.html.erb`を編集<br>

```html:new.html.erb
<%= form_with model: @post do |f| %>
<%= f.label :caption %>
<%= f.text_field :caption %>
<%= f.fields_for :photos do |i| %>
<%= i.file_field :image %>
<% end %>
<%= f.submit "投稿", class: "btn btn-primary" %>
<% end %>
```

+ form_withは Rails5.1から提供されているHTMLフォーム生成メソッドです。<br>
モデルオプションに、先ほどコントローラー定義した `@post` をモデルオブジェクトとして扱います。<br>
こうすることで、URLをHTTPメソッドを自動推測します。今回 `@post` は空なので、createアクションに飛びます。<br>
空ではない時はupdateアクションに飛びます。<br>

+ サーバーを再起動して localhost:3000/poosts/new にアクセスして投稿してみる<br>

+ `$ rails console`を実行<br>

+ `下記を実行`<br>

```
irb(main):001:0> Post.first
```

+ `result`<br>

```
irb(main):001:0> Post.first
  Post Load (3.8ms)  SELECT `posts`.* FROM `posts` ORDER BY `posts`.`id` ASC LIMIT 1
=> #<Post id: 1, caption: "test", user_id: 1, created_at: "2022-09-16 07:31:02.075218000 +0000", updated_at: "2022-09-16 07:31:02.075218000 +0000">
irb(main):002:0>
```

+ 下記を実行<br>

```
irb(main):002:0> Photo.first
```

+ `result`<br>

```
  Photo Load (2.1ms)  SELECT `photos`.* FROM `photos` ORDER BY `photos`.`id` ASC LIMIT 1
=> #<Photo id: 1, image: "ゼブラ_パンプス05.jpg", post_id: 1, created_at: "2022-09-16 07:31:02.093428000 +0000", updated_at: "2022-09-16 07:31:02.093428000 +0000">
irb(main):003:0>
```

### 5. サインイン済みユーザーのみにアクセス許可

+ `app/controllers/posts_controller.rb`を編集<br>

```rb:posts_controller.rb
class PostsController < ApplicationController
  before_action :authenticate_user! # サインインしていない状態でnewアクションやcreateアクションを実行しようとすると、サインインページにレダイレクトされる。

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

  private
  def post_params
    params.require(:post).permit(:caption, photos_attributes: [:image]).merge(user_id: current_user.id)
  end
end
```

### アップロードした画像はコミットしないようにしよう

+ `.gitignore`を編集<br>

```:.gitignore
# See https://help.github.com/articles/ignoring-files for more about ignoring files.
#
# If you find yourself ignoring temporary files generated by your text editor
# or operating system, you probably want to add a global ignore instead:
#   git config --global core.excludesfile '~/.gitignore_global'

# Ignore bundler config.
/.bundle

# Ignore all logfiles and tempfiles.
/log/*
/tmp/*
!/log/.keep
!/tmp/.keep

# Ignore pidfiles, but keep the directory.
/tmp/pids/*
!/tmp/pids/
!/tmp/pids/.keep

# Ignore uploaded files in development.
/storage/*
!/storage/.keep

/public/assets
.byebug_history

# Ignore master key for decrypting credentials and more.
/config/master.key

/public/packs
/public/packs-test
/node_modules
/yarn-error.log
yarn-debug.log*
.yarn-integrity
.DS_Store
public/uploads/ # 追加
```
