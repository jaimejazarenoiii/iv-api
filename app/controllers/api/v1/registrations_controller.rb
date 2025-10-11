module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json
      
      # Override Devise's authenticate_user! requirement
      prepend_before_action :skip_authentication, only: [:create]
      
      def create
        build_resource(sign_up_params)

        resource.save
        
        if resource.persisted?
          # Don't sign in - just return the response with JWT in header
          respond_with resource
        else
          clean_up_passwords resource
          respond_with resource
        end
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            status: { code: 200, message: 'Signed up successfully. Please login to get your token.' },
            data: {
              user: {
                id: resource.id,
                email: resource.email
              }
            }
          }, status: :ok
        else
          # Log errors for debugging
          Rails.logger.error "User creation failed: #{resource.errors.full_messages.join(', ')}"
          Rails.logger.error "Received params: #{params.inspect}"
          
          render json: {
            status: { 
              code: 422,
              message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" 
            },
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def skip_authentication
        # Do nothing - allows signup without authentication
      end

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end

