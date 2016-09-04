class CacheLikeCount < ActiveRecord::Migration
  def up
    execute "update events set likes_count=(select count(*) from likes where event_id=events.id)"
  end

  def down
  end
end
