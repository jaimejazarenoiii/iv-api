module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      # Handle authentication failures
      def failure
        render json: {
          status: {
            code: 401,
            message: 'Login failed. Please check your credentials.'
          },
          errors: ['Invalid email or password.']
        }, status: :unauthorized
      end

      private

      def respond_with(resource, _opts = {})
        # Manually generate JWT token
        token = generate_jwt_token(resource)

        render json: {
          status: { code: 200, message: 'Logged in successfully.' },
          data: {
            user: {
              id: resource.id,
              email: resource.email
            },
            token: token
          }
        }, status: :ok
      end

      def respond_to_on_destroy
        if current_user
          render json: {
            status: { code: 200, message: 'Logged out successfully.' }
          }, status: :ok
        else
          render json: {
            status: { code: 401, message: "Couldn't find an active session." }
          }, status: :unauthorized
        end
      end

      def generate_jwt_token(resource)
        Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first
      end
    end
  end
end
