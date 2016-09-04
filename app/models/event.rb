# Event
class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :prefecture
  has_many :likes
  has_one :detail, foreign_key: 'event_id', class_name: 'EventDetail'

  mount_uploader :thumb, AvatarUploader

  def api_attributes
    { id: id,
      prefecture_id: prefecture_id,
      name: name,
      place: place,
      start_date: start_date.to_s,
      end_date: end_date.to_s,
      url: url,
      desc: desc.to_s,
      like_count: likes.size,
      thumb: thumb.try(&:to_s) || ''
    }
  end
end
