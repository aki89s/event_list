class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.references :user, null: false
      t.integer :target_id, null: false

      t.timestamps null: false
    end
    add_index :follows, [:user_id, :target_id], unique: true
    add_index :follows, :target_id
  end
end
