# 2-1 画像のダウンロード

+ https://www.filepicker.io/api/file/DJLxmdEYQ7iahtBXoPGn から画像をダウンロードする<br>

+ `$ mkdir app/javascript/images`を実行<br>

+ `app/javascript/images`ディレクトリにダウンロードした画像を保存する<br>

+ `config/webpacker.yml`を編集<br>

```yml:webpacker.yml
# Note: You must restart bin/webpack-dev-server for changes to take effect

default: &default
  source_path: app/javascript
  source_entry_path: packs
  public_root_path: public
  public_output_path: packs
  cache_path: tmp/cache/webpacker
  webpack_compile_output: true

  # Additional paths webpack should lookup modules
  # ['app/assets', 'engine/foo/app/assets']
  # additional_paths: [] # コメントアウト
  resolved_paths: ["app/javascript/images", "app/assets/images"] # 追加

  # Reload manifest.json on all requests so we reload latest compiled packs
  cache_manifest: false

  # Extract and emit a css file
  extract_css: false

  static_assets_extensions:
    - .jpg
    - .jpeg
    - .png
    - .gif
    - .tiff
    - .ico
    - .svg
    - .eot
    - .otf
    - .ttf
    - .woff
    - .woff2

  extensions:
    - .mjs
    - .js
    - .sass
    - .scss
    - .css
    - .module.sass
    - .module.scss
    - .module.css
    - .png
    - .svg
    - .gif
    - .jpeg
    - .jpg

development:
  <<: *default
  compile: true

  # Reference: https://webpack.js.org/configuration/dev-server/
  dev_server:
    https: false
    host: localhost
    port: 3035
    public: localhost:3035
    hmr: false
    # Inline should be set to true if using HMR
    inline: true
    overlay: true
    compress: true
    disable_host_check: true
    use_local_ip: false
    quiet: false
    pretty: false
    headers:
      "Access-Control-Allow-Origin": "*"
    watch_options:
      ignored: "**/node_modules/**"

test:
  <<: *default
  compile: true

  # Compile test packs to a separate directory
  public_output_path: packs-test

production:
  <<: *default

  # Production depends on precompilation of packs prior to booting for performance.
  compile: false

  # Extract and emit a css file
  extract_css: true

  # Cache manifest.json for performance
  cache_manifest: true
```

## 2-3 仮のトップページを表示

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  get 'pages/home' # 追加
end
```

+ `$ rails routes`を実行すると下記参照<br>

```
                                  Prefix Verb   URI Pattern                                                                                       Controller#Action
                              pages_home GET    /pages/home(.:format)                                                                             pages#home
           rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
              rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
           rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
     rails_mandrill_inbound_health_check GET    /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
           rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
            rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
          rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
                                         POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
       new_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
      edit_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id/edit(.:format)                                 rails/conductor/action_mailbox/inbound_emails#edit
           rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
                                         PATCH  /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#update
                                         PUT    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#update
                                         DELETE /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#destroy
new_rails_conductor_inbound_email_source GET    /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
   rails_conductor_inbound_email_sources POST   /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
   rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
                      rails_service_blob GET    /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
                rails_service_blob_proxy GET    /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
                                         GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
               rails_blob_representation GET    /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
         rails_blob_representation_proxy GET    /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
                                         GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
                      rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
               update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
                    rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
```

+ [Railsのルーティング](https://railsguides.jp/routing.html) <br>

## 2. コントローラの作成

+ `pages#home` の `pages`がコントローラの名前、`home` がアクション名<br>

+ `$ rails g controller pages`を実行<br>

+ `app/controllers/pages_controller.rb`を編集<br>

```rb:pages_controller.rb
class PagesController < ApplicationController
  def home

  end
end
```

## 4. トップページのビューを作成

+ `$ touch app/views/pages/home.html.erb`を実行<br>

+ `app/views/pages/home.html.erb`を編集<br>

```erb:home.html.erb
<p>ここのページは仮のトップページです。</p>
```

+ http://localhost:3000/pages/home にアクセスしてみる<br>

+ `$ touch config/initializers/rack_profile.rb`を実行<br>

+ `config/initializers/rack_profile.rb`を編集<br>

```rb:rack_profile.rb
Rack::MiniProfiler.config.start_hidden = true
```

+ `サーバーを再起動する`<br>

## 5. rootルーティングの設定

+ `config/routes.rb`を編集<br>

```rb:routes.rb
Rails.application.routes.draw do
  root 'pages#home' # 編集
end
```

+ ルーティングは下記のようになる<br>

`root GET    /   pages#home`<br>

+ locahost:3000 にアクセスしてみる<br>

