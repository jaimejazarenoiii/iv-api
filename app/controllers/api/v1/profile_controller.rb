module Api
  module V1
    class ProfileController < BaseController
      before_action :authenticate_user!

      # GET /api/v1/profile
      def show
        render json: {
          status: { code: 200, message: 'Profile retrieved successfully.' },
          data: {
            profile: profile_json(current_user)
          }
        }, status: :ok
      end

      # PATCH/PUT /api/v1/profile
      def update
        if current_user.update(profile_params)
          render json: {
            status: { code: 200, message: 'Profile updated successfully.' },
            data: {
              profile: profile_json(current_user)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: 'Profile could not be updated.' },
            errors: current_user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/profile/image
      def destroy_image
        if current_user.profile_image.attached?
          current_user.profile_image.purge
          render json: {
            status: { code: 200, message: 'Profile image deleted successfully.' },
            data: {
              profile: profile_json(current_user)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 404, message: 'No profile image found.' },
            errors: ['No profile image to delete.']
          }, status: :not_found
        end
      end

      private

      def profile_params
        params.require(:profile).permit(:first_name, :last_name, :middle_name, :gender, :profile_image)
      end

      def profile_json(user)
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          middle_name: user.middle_name,
          full_name: user.full_name,
          gender: user.gender,
          profile_image_url: user.profile_image_url,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end

