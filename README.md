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