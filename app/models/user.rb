class User < ActiveRecord::Base
  has_many :events
  belongs_to :prefecture

  def api_attributes
    { id: id,
      name: name,
      desc: desc,
      url: url
    }
  end
end
