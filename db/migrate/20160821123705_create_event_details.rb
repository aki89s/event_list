class CreateEventDetails < ActiveRecord::Migration
  def change
    create_table :event_details do |t|
      t.references :event, null: false
      t.integer :price, null: false, default: 0
      t.string :access, limit: 200
      t.string :caution, limit: 3000
      t.timestamps null: false
    end
  end
end
