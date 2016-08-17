class User < ActiveRecord::Base
  has_many :events
  has_many :follows
  has_many :likes
  belongs_to :prefecture

  def api_attributes
    { id: id,
      name: name,
      desc: desc,
      url: url,
      follows: follows.size,
      followers: followers.size
    }
  end

  def followers
    Follow.where(target_id: id)
  end

  def follow?(target)
    follows.pluck(:target_id).include?(target.id)
  end

  def like?(event)
    likes.pluck(:event_id).include?(event.id)
  end
end
