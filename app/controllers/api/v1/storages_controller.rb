module Api
  module V1
    class StoragesController < BaseController
      before_action :authenticate_user!
      before_action :set_storage, only: [:show, :update, :destroy]

      # GET /api/v1/storages
      def index
        @storages = current_user.storages.includes(:parent, :children, :items)

        render json: {
          status: { code: 200, message: 'Storages retrieved successfully.' },
          data: {
            storages: @storages.map { |storage| storage_json(storage) }
          }
        }, status: :ok
      end

      # GET /api/v1/storages/:id
      def show
        render json: {
          status: { code: 200, message: 'Storage retrieved successfully.' },
          data: {
            storage: storage_json(@storage)
          }
        }, status: :ok
      end

      # POST /api/v1/storages
      def create
        @storage = current_user.storages.build(storage_params)

        if @storage.save
          render json: {
            status: { code: 201, message: 'Storage created successfully.' },
            data: {
              storage: storage_json(@storage)
            }
          }, status: :created
        else
          render json: {
            status: { code: 422, message: 'Storage could not be created.' },
            errors: @storage.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/storages/:id
      def update
        if @storage.update(storage_params)
          render json: {
            status: { code: 200, message: 'Storage updated successfully.' },
            data: {
              storage: storage_json(@storage)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: 'Storage could not be updated.' },
            errors: @storage.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/storages/:id
      def destroy
        @storage.destroy
        render json: {
          status: { code: 200, message: 'Storage deleted successfully.' }
        }, status: :ok
      end

      # DELETE /api/v1/storages/:id/image
      def destroy_image
        if @storage.image.attached?
          @storage.image.purge
          render json: {
            status: { code: 200, message: 'Storage image deleted successfully.' },
            data: {
              storage: storage_json(@storage)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 404, message: 'No storage image found.' },
            errors: ['No storage image to delete.']
          }, status: :not_found
        end
      end

      private

      def set_storage
        @storage = current_user.storages.find_by(id: params[:id])
        unless @storage
          render json: {
            status: { code: 404, message: 'Storage not found.' },
            errors: ['Storage does not exist or you do not have permission to access it.']
          }, status: :not_found
        end
      end

      def storage_params
        params.require(:storage).permit(:name, :description, :parent_id, :space_id, :image)
      end

      def storage_json(storage)
        {
          id: storage.id,
          name: storage.name,
          description: storage.description,
          space_id: storage.space_id,
          space_name: storage.space&.name,
          parent_id: storage.parent_id,
          image_url: storage.image_url,
          children_count: storage.children.count,
          items_count: storage.items.count,
          created_at: storage.created_at,
          updated_at: storage.updated_at
        }
      end
    end
  end
end

