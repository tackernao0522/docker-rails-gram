class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.references :post, foregin_key: true, null: false
      t.references :user, foregin_key: true, null: false
      t.timestamps
    end
  end
end
