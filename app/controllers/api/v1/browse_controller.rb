module Api
  module V1
    class BrowseController < BaseController
      before_action :authenticate_user!

      # GET /api/v1/browse/spaces
      # Minimal payload for first step in the picker
      def spaces
        spaces = current_user.spaces

        render json: {
          status: { code: 200, message: 'Spaces retrieved successfully.' },
          data: {
            spaces: spaces.map { |space| browse_space_json(space) }
          }
        }, status: :ok
      end

      # GET /api/v1/browse/storages
      # Params:
      #   space_id: list top-level storages in a space
      #   parent_id: list child storages of a storage
      def storages
        if params[:parent_id].present?
          parent = current_user.storages.find_by(id: params[:parent_id])
          return not_found('Parent storage') unless parent
          storages = parent.children
        elsif params[:space_id].present?
          space = current_user.spaces.find_by(id: params[:space_id])
          return not_found('Space') unless space
          storages = space.storages.where(parent_id: nil)
        else
          return render json: {
            status: { code: 422, message: 'Invalid parameters.' },
            errors: ['Provide either space_id for top-level storages or parent_id for children.']
          }, status: :unprocessable_entity
        end

        render json: {
          status: { code: 200, message: 'Storages retrieved successfully.' },
          data: {
            storages: storages.map { |s| browse_storage_json(s) }
          }
        }, status: :ok
      end

      private

      def browse_space_json(space)
        {
          id: space.id,
          name: space.name,
          description: space.description,
          image_url: space.image_url,
          has_children: space.storages.exists?,
          storages_count: space.storages.count
        }
      end

      def browse_storage_json(storage)
        {
          id: storage.id,
          name: storage.name,
          space_id: storage.space_id,
          parent_id: storage.parent_id,
          image_url: storage.image_url,
          location_path: storage.location_path,
          has_children: storage.children.exists?,
          children_count: storage.children.count
        }
      end

      def not_found(resource)
        render json: {
          status: { code: 404, message: "#{resource} not found." }
        }, status: :not_found
      end
    end
  end
end


