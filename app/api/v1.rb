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
  end
end
