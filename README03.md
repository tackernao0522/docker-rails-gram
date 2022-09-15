## 3-6 サインイン画面の見た目を整える

### 1. サインイン画面のビューを作成

+ `app/views/devise/sessions/new.html.erb`を編集<br>

```html:new.html.erb
<div class="main">
  <div class="card devise-card">
    <div class="form-wrap">
      <div class="form-group text-center">
        <h2 class="logo-img mx-auto"></h2>
      </div>
      <%= form_with scope: resource, as: resource_name, url: session_path(resource_name), local: true do |f| %>
      <%= devise_error_messages! %>
      <div class="form-group">
        <%= f.email_field :email, autofocus: true, placeholder: "メールアドレス", class: "form-control" %>
      </div>

      <div class="form-group">
        <%= f.password_field :password, autocomplete: "off", placeholder: "パスワード", class: "form-control" %>
      </div>

      <div class="actions">
        <%= f.submit "ログインする", class: "btn btn-primary w-100" %>
      </div>
      <% end %>

      <br>

      <p class="devise-link">
        アカウントをお持ちですか？
        <%= link_to "登録する", new_user_registration_path %>
      </p>
    </div>
  </div>
</div>
```

+ http://localhost:3000/users/sign_in にアクセスしてみる<br>
