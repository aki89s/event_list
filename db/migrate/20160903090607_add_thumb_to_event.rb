class AddThumbToEvent < ActiveRecord::Migration
  def change
    add_column :events, :thumb, :string
  end
end
