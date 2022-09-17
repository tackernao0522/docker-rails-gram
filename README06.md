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
