class AddBgImageToUser < ActiveRecord::Migration
  def change
    add_column :users, :bg_image, :string
  end
end
