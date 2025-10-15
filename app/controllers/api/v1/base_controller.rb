module Api
  module V1
    class BaseController < ApplicationController
      respond_to :json

      private

      # Authenticate user from JWT token
      def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last
        return render_unauthorized unless token

        begin
          decoded_token = Warden::JWTAuth::TokenDecoder.new.call(token)
          @current_user = User.find(decoded_token['sub'])
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
          render_unauthorized
        end
      end

      # Get current authenticated user
      def current_user
        @current_user
      end

      # Render unauthorized response
      def render_unauthorized
        render json: {
          status: { code: 401, message: 'Unauthorized. Please login.' },
          errors: ['Invalid or missing authentication token.']
        }, status: :unauthorized
      end
    end
  end
end

