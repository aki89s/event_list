class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false, default: ''
      t.string :uuid, null: false
      t.integer :sex, default: 2
      t.datetime :birthday, null: false
      t.string :desc, default: ''
      t.integer :publish, default: 0
      t.references :prefecture, null: false

      t.timestamps null: false
    end
    add_index :users, :uuid, unique: true
    add_index :users, :sex
    add_index :users, :prefecture_id
  end
end
