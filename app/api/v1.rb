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

      post :update do
        user = User.find_by(uuid: params['uuid'])
        if user.blank?
          user = User.create(uuid: params['uuid'], name: params['name'], desc: params['desc'])
          response(user: user.api_attributes, create: true)
        end
        user.update(uuid: params['uuid'], name: params['name'], desc: params['desc'])
        response(user: user.api_attributes, create: false)
      end
    end

    resource :events do
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
  end
end
