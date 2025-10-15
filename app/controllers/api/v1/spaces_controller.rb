module Api
  module V1
    class SpacesController < BaseController
      before_action :authenticate_user!
      before_action :set_space, only: [:show, :update, :destroy]

      # GET /api/v1/spaces
      def index
        @spaces = current_user.spaces.includes(:storages)

        render json: {
          status: { code: 200, message: 'Spaces retrieved successfully.' },
          data: {
            spaces: @spaces.map { |space| space_json(space) }
          }
        }, status: :ok
      end

      # GET /api/v1/spaces/:id
      def show
        render json: {
          status: { code: 200, message: 'Space retrieved successfully.' },
          data: {
            space: space_json(@space, include_storages: true)
          }
        }, status: :ok
      end

      # POST /api/v1/spaces
      def create
        @space = current_user.spaces.build(space_params)

        if @space.save
          render json: {
            status: { code: 201, message: 'Space created successfully.' },
            data: {
              space: space_json(@space)
            }
          }, status: :created
        else
          render json: {
            status: { code: 422, message: 'Space could not be created.' },
            errors: @space.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/spaces/:id
      def update
        if @space.update(space_params)
          render json: {
            status: { code: 200, message: 'Space updated successfully.' },
            data: {
              space: space_json(@space)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: 'Space could not be updated.' },
            errors: @space.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/spaces/:id
      def destroy
        @space.destroy
        render json: {
          status: { code: 200, message: 'Space deleted successfully.' }
        }, status: :ok
      end

      # DELETE /api/v1/spaces/:id/image
      def destroy_image
        if @space.image.attached?
          @space.image.purge
          render json: {
            status: { code: 200, message: 'Space image deleted successfully.' },
            data: {
              space: space_json(@space)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 404, message: 'No space image found.' },
            errors: ['No space image to delete.']
          }, status: :not_found
        end
      end

      private

      def set_space
        @space = current_user.spaces.find_by(id: params[:id])
        unless @space
          render json: {
            status: { code: 404, message: 'Space not found.' },
            errors: ['Space does not exist or you do not have permission to access it.']
          }, status: :not_found
        end
      end

      def space_params
        params.require(:space).permit(:name, :space_type, :description, :image)
      end

      def space_json(space, include_storages: false)
        result = {
          id: space.id,
          name: space.name,
          space_type: space.space_type,
          description: space.description,
          image_url: space.image_url,
          storages_count: space.storages.count,
          created_at: space.created_at,
          updated_at: space.updated_at
        }

        if include_storages
          result[:storages] = space.storages.map do |storage|
            {
              id: storage.id,
              name: storage.name,
              items_count: storage.items.count
            }
          end
        end

        result
      end
    end
  end
end


