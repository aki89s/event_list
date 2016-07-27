class User < ActiveRecord::Base
  has_many :events
  has_many :follows
  belongs_to :prefecture

  def api_attributes
    { id: id,
      name: name,
      desc: desc,
      url: url
    }
  end

  def follow?(target)
    follows.pluck(:target_id).include?(target.id)
  end
end
