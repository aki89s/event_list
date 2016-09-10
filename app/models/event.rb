# Event
class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :prefecture
  has_many :likes
  has_one :detail, foreign_key: 'event_id', class_name: 'EventDetail'

  default_scope { includes(:detail) }
  scope :now_playing, -> { where(arel_table[:start_date].lt Time.zone.today).where(arel_table[:end_date].gt Time.zone.today) }
  scope :scheduled, -> { where(arel_table[:start_date].gteq Time.zone.today) }
  scope :closed, -> { where(arel_table[:end_date].lt Time.zone.today) }
  scope :prefecture, ->(prefecture) { where(prefecture_id: prefecture.id) if prefecture.name != '未設定' }
  scope :category, ->(category) { where(category_id: category.id) if category.name != 'すべて' }

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

  def now_playing
    where(arel_table[:start_date].lt date).where(arel_table[:end_date].gt date)
  end
end
