class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :prefecture
  has_many :likes

  def api_attributes
    { id: id,
      prefecture_id: prefecture_id,
      name: name,
      place: place,
      start_date: start_date.to_s,
      end_date: end_date.to_s,
      url: url
    }
  end
end
