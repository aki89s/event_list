class AddDescToEvent < ActiveRecord::Migration
  def change
    add_column :events, :desc, :string, limit: 3000
  end
end
