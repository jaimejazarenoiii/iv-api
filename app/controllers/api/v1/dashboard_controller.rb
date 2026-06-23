module Api
  module V1
    class DashboardController < BaseController
      before_action :authenticate_user!

      # GET /api/v1/dashboard
      def index
        # Fetch recent data for the authenticated user
        recent_spaces = current_user.spaces
                                   .includes(:storages)
                                   .order(updated_at: :desc)
                                   .limit(5)

        recent_storages = current_user.storages
                                     .includes(:space, :items, :children)
                                     .order(updated_at: :desc)
                                     .limit(5)

        recent_items = current_user.items
                                  .includes(:storage, :storage => :space)
                                  .order(updated_at: :desc)
                                  .limit(5)

        render json: {
          status: { code: 200, message: 'Dashboard data retrieved successfully.' },
          data: {
            spaces: recent_spaces.map { |space| space_json(space) },
            storages: recent_storages.map { |storage| storage_json(storage) },
            items: recent_items.map { |item| item_json(item) }
          }
        }, status: :ok
      end

      private

      def space_json(space)
        {
          id: space.id,
          name: space.name,
          description: space.description,
          image_url: space.image_url,
          storages_count: space.storages.where(parent_id: nil).count,
          substorages_count: space.total_substorages_count,
          items_count: space.total_items_count_for_space,
          created_at: space.created_at,
          updated_at: space.updated_at
        }
      end

      def storage_json(storage)
        {
          id: storage.id,
          name: storage.name,
          description: storage.description,
          space_id: storage.space_id,
          space_name: storage.space.name,
          location_path: storage.location_path,
          items_count: storage.items.count,
          substorages_count: storage.substorages_count,
          total_items_count: storage.total_items_count,
          created_at: storage.created_at,
          updated_at: storage.updated_at
        }
      end

      def item_json(item)
        {
          id: item.id,
          name: item.name,
          notes: item.notes,
          quantity: item.quantity,
          unit: item.unit,
          storage_id: item.storage_id,
          storage_name: item.storage.name,
          space_name: item.storage.space.name,
          image_url: item.image_url,
          created_at: item.created_at,
          updated_at: item.updated_at
        }
      end
    end
  end
end
