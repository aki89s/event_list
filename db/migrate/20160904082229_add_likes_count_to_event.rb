class AddLikesCountToEvent < ActiveRecord::Migration
  def change
    add_column :events, :likes_count, :integer, default: 0, null: false
  end
end
