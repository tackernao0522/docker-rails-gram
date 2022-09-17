# 8-1 モデルの作成

## 1. モデルの作成

```
コメントの内容
どの投稿にコメントをしたか投稿の情報
誰がコメントしたかユーザーの情報
```

### Commentモデルの作成

|カラム名|データ型|
|:---:|:---:|
|comment|text|
|post|references|
|user|references|

+ `$ rails g model comment`を実行<br>

+ `db/migrate/create_comment.rb`を編集<br>

```rb:create_comment.rb
class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :comment, null: false
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

### UserモデルとCommentモデルのアソシエーションの設定

```
ユーザーは複数のコメントをすることができる
コメントAに関して、コメントAをしたユーザーは一人しかしない

UserモデルとCommentモデルは「1対多」の関係になる
```

+ `app/models/user.rb`を編集<br>

```rb:user.rb
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :likes
  has_many :comments # 追加

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

+ `app/models/comment.rb`を編集<br>

```rb:comment.rb
class Comment < ApplicationRecord
  belongs_to :user
end
```

### PostモデルとCommentモデルのアソシエーションの設定

```
一つの投稿は複数のコメントを持つことができる
コメントAに関して、コメントAに紐づく投稿は一つしかない

PostモデルとCommentモデルは「1対多」の関係になります。
```

+ `app/models/post.rb`を編集<br>

```rb:post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy
  has_many :likes, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :comments, dependent: :destroy # 追加

  accepts_nested_attributes_for :photos

  def liked_by(user)
    # user_idとpost_idが一致するlikeを検索する
    Like.find_by(user_id: user.id, post_id: id)
  end
end
```

+ [Active Record の関連付け (アソシエーション) :dependent](https://railsguides.jp/association_basics.html#belongs-to%E3%81%AE%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3-dependent) <br>

+ `app/models/comment.rb`を編集<br>

```rb:comment.rb
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post # 追加
end
```