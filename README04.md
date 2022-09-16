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
