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
    end

    resource :events do
      get :index do
        events = Event.all
        response(events: events.map(&:api_attributes))
      end

      get :show do
        user = User.find_by(uuid: params['uuid'])
        event = Event.find_by(id: params[:event_id])
        response(event: event.api_attributes,
                 user: event.user.api_attributes,
                 follow_status: user.follow?(event.user),
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
                     url: params['url'])

        response(create: true)
      end
    end

    resource :likes do
      post :create do
        user = User.find_by(uuid: params['uuid'])
        event = Event.find_by(id: params['event_id'])
        response(create: false) if user.blank? || event.blank?

        Like.create(user: user, event: event)
        response(create: true)
      end
    end
  end
end
