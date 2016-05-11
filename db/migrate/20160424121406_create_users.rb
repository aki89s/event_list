class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false, default: ''
      t.string :uuid, null: false
      t.integer :sex, default: 2
      t.datetime :birthday, null: false, default: DateTime.now
      t.string :desc, default: ''
      t.string :url, default: '', limit: 200
      t.integer :publish, default: 0
      t.references :prefecture, null: false, default: 48

      t.timestamps null: false
    end
    add_index :users, :uuid, unique: true
    add_index :users, :sex
    add_index :users, :prefecture_id
  end
end
