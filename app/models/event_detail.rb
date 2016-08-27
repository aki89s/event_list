# EventDetails
class EventDetail < ActiveRecord::Base
  belongs_to :event

  def api_attributes
    { id: id,
      price: price.to_s,
      access: access,
      caution: caution
    }
  end
end
