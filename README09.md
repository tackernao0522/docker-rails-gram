# 第10章: トラブルシューティング

## 10-2 デバッグ方法を知ろう

### pry-railsの導入

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
  gem 'pry-rails' ### 追加
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
gem 'mini_magick'
```

+ `$ bundle install`を実行<br>

+ `$ docker ps`を実行<br>

```
CONTAINER ID   IMAGE              COMMAND                  CREATED         STATUS         PORTS                               NAMES
7770a586f983   techpit_gram-web   "entrypoint.sh bash …"   9 seconds ago   Up 5 seconds   0.0.0.0:3000->3000/tcp              rails-web
8664f678170d   mysql:5.7          "docker-entrypoint.s…"   9 seconds ago   Up 8 seconds   0.0.0.0:3306->3306/tcp, 33060/tcp   rails-db
```

### 実際にpry-railsを使って、変数の中身を確認しよう

+ `app/controllers/posts_controller.rb`を編集<br>

```rb:posts_controller.rb
class PostsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_post, only: %i(show destroy)

  def new
    @post = Post.new
    @post.photos.build
  end

  def create
    @post = Post.new(post_params)
    binding.pry # 追加
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
  end

  def destroy
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

  def set_post
    @post = Post.find_by(id: params[:id])
  end
end
```

+ `$ docker attach rails-web`を実行<br>

+ 何か投稿してみる<br>

```
From: /app/app/controllers/posts_controller.rb:13 PostsController#create:

    11: def create
    12:   @post = Post.new(post_params)
 => 13:   binding.pry
    14:   if @post.photos.present?
    15:     @post.save
    16:     redirect_to root_path
    17:     flash[:notice] = "投稿が保存されました"
    18:   else
    19:     redirect_to root_path

<page break> --- Press enter to continue ( q<enter> to break ) --- <page break>
```

+ `上記の中で `q` + `enter`をする<br>

```
From: /app/app/controllers/posts_controller.rb:13 PostsController#create:

    11: def create
    12:   @post = Post.new(post_params)
 => 13:   binding.pry
    14:   if @post.photos.present?
    15:     @post.save
    16:     redirect_to root_path
    17:     flash[:notice] = "投稿が保存されました"
    18:   else
    19:     redirect_to root_path

<page break> --- Press enter to continue ( q<enter> to break ) --- <page break>
q
[1] pry(#<PostsController>)> @post ### Enterする
```

```
From: /app/app/controllers/posts_controller.rb:13 PostsController#create:

    11: def create
    12:   @post = Post.new(post_params)
 => 13:   binding.pry
    14:   if @post.photos.present?
    15:     @post.save
    16:     redirect_to root_path
    17:     flash[:notice] = "投稿が保存されました"
    18:   else
    19:     redirect_to root_path

<page break> --- Press enter to continue ( q<enter> to break ) --- <page break>
q
[1] pry(#<PostsController>)> @post
=> #<Post:0x00007f9e4809c548 id: nil, caption: "処理が止まるかどうかのテストです", user_id: 1, created_at: nil, updated_at: nil> ### result
[2] pry(#<PostsController>)>
```

+ `exit` => `enter`を実行して解除してコントローラに記述した`binding.pry`を削除する<br>

### rails console

+ `$ rails console`を実行<br>

```
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                                          0.0s
Running via Spring preloader in process 23
Loading development environment (Rails 6.1.7)
[1] pry(main)>
```

### テーブルの情報を確認する

```
[+] Running 1/0
 ⠿ Container rails-db  Running                                                                                                                                                                                                          0.0s
Running via Spring preloader in process 23
Loading development environment (Rails 6.1.7)
[1] pry(main)> Post.all
```

```
[1] pry(main)> Post.all
=>   Post Load (5.1ms)  SELECT `posts`.* FROM `posts`
[#<Post:0x000055f4de9b06a8 id: 1, caption: "test", user_id: 1, created_at: Fri, 16 Sep 2022 14:27:03.809374000 UTC +00:00, updated_at: Fri, 16 Sep 2022 14:27:03.809374000 UTC +00:00>,
 #<Post:0x000055f4daa33890 id: 2, caption: "処理が止まるかどうかのテストです", user_id: 1, created_at: Sun, 18 Sep 2022 04:24:15.694523000 UTC +00:00, updated_at: Sun, 18 Sep 2022 04:24:15.694523000 UTC +00:00>]
[2] pry(main)>
```
