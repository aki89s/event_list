# api
module V1
  # api
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    # SUCCESS = 0
    # FAILURE = 400

    helpers do
      def response(obj = nil)
        if obj.nil?
          return {}
        else
          return obj
        end
      end
    end

    resource :users do
      get :index do
        response
      end

      get :show do
        user = User.find_by(uuid: params['uuid'])
        target = User.find_by(id: params['user_id'])
        response(user: target.api_attributes,
                 follow_status: user.follow?(target),
                 events: target.events.map(&:api_attributes))
      end

      get :my_profile do
        user = User.find_by(uuid: params['uuid'])
        response(user: user.api_attributes,
                 user_events: user.events.map(&:api_attributes),
                 like_events: user.likes.map(&:event).map(&:api_attributes))
      end

      get :follows do
        user = User.find_by(uuid: params['uuid'])
        follows = []
        if params[:follower] == '1'
          follows = Follow.where(target_id: user.id).map do |r|
            f = r.user.api_attributes
            f['is_follow'] = user.follow?(r.user)
            f
          end
        else
          follows = user.follows.map { |r| User.find_by(id: r.target_id) }
          follows = follows.map do |r|
            f = r.api_attributes
            f['is_follow'] = user.follow?(r)
            f
          end
        end
        response(follows: follows)
      end

      post :update do
        user = User.find_by(uuid: params['uuid'])
        if user.blank?
          user = User.create(uuid: params['uuid'], name: params['name'], desc: params['desc'])
          response(user: user.api_attributes, create: true)
        end
        user.update(uuid: params['uuid'], name: params['name'], desc: params['desc'])
        response(user: user.api_attributes, create: false)
      end

      post :follow do
        user = User.find_by(uuid: params['uuid'])
        target = User.find_by(id: params['target_id'])
        response(success: false) if user.blank? || target.blank?
        follow = Follow.find_by(user: user, target_id: target.id)
        if follow
          response(success: false)
          return
        end
        Follow.create(user: user, target_id: target.id)
        response(success: true, follow_status: user.follow?(target))
      end

      post :unfollow do
        user = User.find_by(uuid: params['uuid'])
        target = User.find_by(id: params['target_id'])
        response(success: false) if user.blank? || target.blank?
        follow = Follow.find_by(user: user, target_id: target.id)
        if follow.blank?
          response(success: false)
          return
        end
        follow.destroy
        response(success: true, follow_status: user.follow?(target))
      end

      get :events do
        user = User.find_by(uuid: params['uuid'])
        response(events: user.likes.map(&:event).map(&:api_attributes))
      end

      post :change_avatar do
        user = User.find_by(uuid: params['uuid'])
        params['image']['filename'] = params['uuid'] + params['image']['filename']
        if params['selectedImage'] == '0'
          user.update(avatar: params['image'])
        else
          user.update(bg_image: params['image'])
        end
        response(user: user.api_attributes)
      end
    end

    resource :events do
      get :index do
        prefecture = params['prefecture'] == '0' ? Prefecture.find_by(id: 48) : Prefecture.find_by(id: params['prefecture'])
        category = params['category'] == '0' ? Category.find_by(id: 0) : Category.find_by(id: params['category'].to_i + 1)
        events = Event.now_playing.prefecture(prefecture).category(category)
        categories = Category.pluck(:name)
        response(events: events.map(&:api_attributes), categories: categories)
      end

      get :popular do
        prefecture = params['prefecture'] == '0' ? Prefecture.find_by(id: 48) : Prefecture.find_by(id: params['prefecture'])
        category = params['category'] == '0' ? Category.find_by(id: 1) : Category.find_by(id: params['category'].to_i + 1)
        events = Event.scheduled.prefecture(prefecture).category(category).order(likes_count: :desc).map(&:api_attributes)
        categories = Category.pluck(:name)
        response(events: events, categories: categories)
      end

      get :show do
        user = User.includes(:events).find_by(uuid: params['uuid'])
        event = Event.includes(:detail).find_by(id: params[:event_id])
        response(event: event.api_attributes,
                 detail: event.detail.try(&:api_attributes),
                 user: event.user.api_attributes,
                 like_status: user.like?(event),
                 users_event: user.events.include?(event)
                )
      end

      post :create do
        user = User.find_by(uuid: params['uuid'])
        response(create: false) if user.blank?

        Event.create(user: user,
                     prefecture: Prefecture.find_by(name: params['prefecture']),
                     name: params['name'],
                     place: params['address'],
                     start_date: params['start_date'].gsub(/[^0-9|:]/, '-').to_datetime,
                     end_date: params['end_date'].gsub(/[^0-9|:]/, '-').to_datetime,
                     url: params['url'],
                     desc: params['desc']
                    )

        response(create: true)
      end

      post :update do
        user = User.find_by(uuid: params['uuid'])
        response(update: false) if user.blank?

        event = Event.find_by(id: params['event_id'])
        response(update: false) if event.blank?

        event.update(user: user,
                     prefecture: Prefecture.find_by(name: params['prefecture']),
                     name: params['name'],
                     place: params['address'],
                     start_date: params['start_date'].gsub(/[^0-9|:]/, '-').to_datetime,
                     end_date: params['end_date'].gsub(/[^0-9|:]/, '-').to_datetime,
                     url: params['url'],
                     desc: params['desc']
                    )
        response(update: true)
      end

      post :create_with_image do
        user = User.find_by(uuid: params['uuid'])
        if user.blank?
          response(create: false)
          return
        end

        params['image']['filename'] = params['uuid'] + params['image']['filename']
        Event.create(user: user,
                     prefecture: Prefecture.find_by(name: params['prefecture']),
                     name: params['name'],
                     place: params['address'],
                     start_date: params['start_date'].gsub(/[^0-9|:]/, '-').to_datetime,
                     end_date: params['end_date'].gsub(/[^0-9|:]/, '-').to_datetime,
                     url: params['url'],
                     desc: params['desc'],
                     thumb: params['image']
                    )
        response(create: true)
      end
    end

    resource :event_details do
      get :show do
        event = Event.find_by(id: params['event_id'])
        if event.blank? || event.detail.blank?
          response(detail: false)
          return {}
        end

        response(detail: event.detail.api_attributes)
      end

      post :create_or_update do
        user = User.find_by(uuid: params['uuid'])
        response(create: false, update: false) if user.blank?

        event = Event.find_by(id: params['event_id'])
        if event.detail.blank?
          detail = EventDetail.create(event: event,
                                      price: params['price'],
                                      access: params['access'],
                                      caution: params['caution']
                                     )
          response(create: true, update: false, detail: detail.api_attributes) if event.blank?
          return
        else
          event.detail.update(event: event,
                              price: params['price'],
                              access: params['access'],
                              caution: params['caution']
                             )
          response(create: false, update: true, detail: event.detail.api_attributes) if event.blank?
        end
      end
    end

    resource :likes do
      post :create_or_destroy do
        user = User.find_by(uuid: params['uuid'])
        event = Event.find_by(id: params['event_id'])
        response(create: false) if user.blank? || event.blank?

        if user.like? event
          user.likes.find_by(event_id: event.id).destroy
        else
          Like.create(user: user, event: event)
        end
        response(like_status: user.like?(event))
      end
    end
  end
end
