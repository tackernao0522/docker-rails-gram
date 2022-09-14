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

## 2-4 Bootstrapの導入

### 2. BootstrapをWebpackerで導入

+ `$ yarn add jquery bootstrap popper.js`を実行<br>

+ `config/webpack/environment.js`を編集<br>

```js:environment.js
const { environment } = require('@rails/webpacker')

module.exports = environment

// 追加
const webpack = require('webpack')
environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    Popper: ['popper.js', 'default']
  })
)
```

+ `$ mkdir app/javascript/stylesheets && touch $_/application.scss`を実行<br>

+ `app/javascript/stylesheets/application.scss`を編集<br>

```scss:application.scss
@import '~bootstrap/scss/bootstrap';
```

+ `app/javascript/packs/applicattion.js`を編集<br>

```js:application.js
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import 'bootstrap'; // 追加
import '../stylesheets/application'; // 追加
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

+ `app/views/layouts/appliction.html.erb`を編集<br>

```html:applictioan.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>App</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

    <!-- 追加 -->
    <%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= yield %>
  </body>
</html>
```

+ `app/views/pages/home.html.erb`を編集<br>

```html:home.html.erb
<p>ここのページは仮のトップページです。</p>

<!-- 追記 -->
<%= link_to "仮のボタンです", "#", class: "btn btn-primary" %>
```

+ `package.json`を編集<br>

```json:package.json
{
  "name": "app",
  "private": true,
  "dependencies": {
    "@rails/actioncable": "^6.0.0",
    "@rails/activestorage": "^6.0.0",
    "@rails/ujs": "^6.0.0",
    "@rails/webpacker": "5.4.3",
    "bootstrap": "^4.5.3", // 修正
    "jquery": "^3.6.1",
    "popper.js": "^1.16.1",
    "turbolinks": "^5.2.0",
    "webpack": "^4.46.0",
    "webpack-cli": "^3.3.12"
  },
  "version": "0.1.0",
  "devDependencies": {
    "webpack-dev-server": "^3"
  }
}
```

+ `yarn.lock`を`node_modules`を削除して再度`$ yarn install`する<br>

# 2-5 ナビゲーションヘッダーの作成

+ [Bootstrapの公式ドキュメントのNavbar](https://getbootstrap.com/docs/4.1/components/navbar/) <br>

1. ナビゲーションヘッダーのビューを作成<br>

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
  <!-- 追加 -->
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
            <%= link_to "", "#", class: "nav-link commonNavIcon profile-icon" %>
          </li>
        </ul>
      </div>
    </div>
  </nav>
  <!-- ここまで -->

  <%= yield %>
</body>

</html>
```

+ [link_to](http://railsdoc.com/references/link_to) <br>

## 2. ナビゲーションヘッダーのscssファイルをインポート

+ `app/javascript/stylesheets/application.scss`を編集<br>

```scss:application.scss
@import '~bootstrap/scss/bootstrap';
@import 'layouts/navbar'; // 追加
```

+ `$ mkdir app/javascript/stylesheets/layouts && touch $_/navbar.scss`を実行<br>

+ `app/javascript/stylesheets/layouts/navbar.scss`を編集<br>

```scss:navbar.scss
.navbar {
  background-color: #fff;
  border-bottom: 1px solid rgba(0, 0, 0, 0.0975);
  height: 77px;
  &__brand {
    height: 35px;
    width: 176px;
    background-size: 114px;
  }
  &__mainLogo {
    background-repeat: no-repeat;
    background-image: url('~logo.png');
  }
  &-nav {
    & > li {
      margin-left: 20px;
      &:first-child {
        margin-left: 0;
      }
      .commonNavIcon {
        height: 24px;
        width: 24px;
        background-size: 22px !important;
        background-repeat: no-repeat;
      }
      .profile-icon {
        background-image: url('~parts3.png');
      }
    }
  }
}
```

+ localhost:3000 にアクセスして確認<br>

## 4. 部分テンプレートを使って共通化

+ `$ mkdir app/views/partial && touch $_/_navbar.html.erb`を編集<br>

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
          <%= link_to "", "#", class: "nav-link commonNavIcon profile-icon" %>
        </li>
      </ul>
    </div>
  </div>
</nav>
```

+ `app/views/layouts/applictioan.html.erb`を編集<br>

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
  <%= render 'partial/navbar' %> <!-- 編集 -->

  <%= yield %>
</body>

</html>
```

+ [Action View の概要](https://railsguides.jp/action_view_overview.html#%E3%83%91%E3%83%BC%E3%82%B7%E3%83%A3%E3%83%AB) <br>

+ localhost:3000 にアクセスしてみる<br>
