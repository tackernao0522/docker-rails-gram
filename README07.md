# 7章: いいね機能

## 7-1 モデルの作成

### Likeモデルを作成

|カラム名|データ型|
|:---:|:---:|
|post|references|
|user|references|

+ `$ rails g model like`を実行<br>

+ `db/migrate/create_likes.rb`を編集<br>

```rb:create_likes.rb
class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
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

### UserモデルとLikeモデルのアソシエーションの設定

```
ユーザーは複数のいいねをすることができる
とあるいいねAに関して、いいねAをしたユーザーは1人しかいない

UserモデルとLikeモデルは「1対多」の関係になる
```

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :likes # 追加

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

+ `app/models/like.rb`を編集<br>

```rb:like.rb
class Like < ApplicationRecord
  belongs_to :user # 追加
end
```

### PostモデルとLikeモデルのアソシエーション設定

```
一つの投稿は複数のいいねを持つことができる
いいねAに関して、いいねAに紐づく投稿は一つしかない

PostモデルとLikeモデルは「1対多」の関係になる
```

+ `app/models/post.rb`を編集<br>

```rb:post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy
  has_many :likes, -> { order(created_at: :desc) }, dependent: :destroy

  accepts_nested_attributes_for :photos
end
```

+ [Active Record の関連付け (アソシエーション) :dependent](https://railsguides.jp/association_basics.html#belongs-to%E3%81%AE%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3-dependent) <br>


+ `app/models/like.rb`を編集<br>

```rb:like.rb
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post # 追加
end
```

### 3. バリデーションの設定

+ `app/models/like.rb`を編集<br>

```rb:like.rb
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id } # 追加 user_idとpost_idの組み合わせが重複しないことを検証している
end
```

+ [Active Recordバリデーション uniqueness](https://railsguides.jp/active_record_validations.html#uniqueness) <br>
