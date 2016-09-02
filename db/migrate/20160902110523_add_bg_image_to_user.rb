class AddBgImageToUser < ActiveRecord::Migration
  def change
    add_column :users, :bg_image, :string, null: false
  end
end
