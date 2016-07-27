class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :user, null: false
      t.references :event, null: false

      t.timestamps null: false
    end
  end
end
