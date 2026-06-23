module Api
  module V1
    class StoragesController < BaseController
      before_action :authenticate_user!
      before_action :set_storage, only: [:show, :update, :destroy, :move]

      # GET /api/v1/storages
      # or GET /api/v1/spaces/:space_id/storages
      def index
        if params[:space_id].present?
          space = current_user.spaces.find_by(id: params[:space_id])
          return render json: { status: { code: 404, message: 'Space not found.' } }, status: :not_found unless space
          @storages = space.storages.includes(:parent, :children, :items)
        else
          @storages = current_user.storages.includes(:parent, :children, :items)
        end

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
            storage: storage_json(@storage, include_children: true, include_items: true)
          }
        }, status: :ok
      end

      # POST /api/v1/storages/:id/move
      # Move a storage to a different space or parent storage
      # Params: destination_space_id (optional), destination_parent_id (optional)
      # One of destination_space_id or destination_parent_id must be provided.
      def move
        destination_space_id = params[:destination_space_id]
        destination_parent_id = params[:destination_parent_id]

        if destination_parent_id.present?
          new_parent = current_user.storages.find_by(id: destination_parent_id)
          return render json: { status: { code: 404, message: 'Destination parent storage not found.' } }, status: :not_found unless new_parent
          # When moving under a parent, space should follow the parent space
          @storage.space = new_parent.space
          @storage.parent = new_parent
        elsif destination_space_id.present?
          new_space = current_user.spaces.find_by(id: destination_space_id)
          return render json: { status: { code: 404, message: 'Destination space not found.' } }, status: :not_found unless new_space
          @storage.space = new_space
          @storage.parent = nil
        else
          return render json: {
            status: { code: 422, message: 'Invalid parameters.' },
            errors: ['Provide destination_parent_id or destination_space_id']
          }, status: :unprocessable_entity
        end

        if @storage.save
          render json: {
            status: { code: 200, message: 'Storage moved successfully.' },
            data: { storage: storage_json(@storage) }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: 'Storage could not be moved.' },
            errors: @storage.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/storages
      # or POST /api/v1/spaces/:space_id/storages
      def create
        if current_user.limit_reached?(:storages)
          return render_limit_error(:storages)
        end

        @storage = current_user.storages.build(storage_params)
        if params[:space_id].present?
          space = current_user.spaces.find_by(id: params[:space_id])
          return render json: { status: { code: 404, message: 'Space not found.' } }, status: :not_found unless space
          @storage.space = space
        end

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

      def storage_json(storage, include_children: false, include_items: false)
        result = {
          id: storage.id,
          name: storage.name,
          description: storage.description,
          space_id: storage.space_id,
          space_name: storage.space&.name,
          parent_id: storage.parent_id,
          image_url: storage.image_url,
          location_path: storage.location_path,
          children_count: storage.children.count,
          items_count: storage.items.count,
          created_at: storage.created_at,
          updated_at: storage.updated_at
        }

        if include_children
          sub_storage_page = params[:sub_storage_page]&.to_i || 1
          sub_storage_per_page = 10
          sub_storage_offset = (sub_storage_page - 1) * sub_storage_per_page
          
          children = storage.children.limit(sub_storage_per_page).offset(sub_storage_offset)
          total_children = storage.children.count
          
          result[:children] = {
            data: children.map { |child| storage_json(child) },
            pagination: {
              current_page: sub_storage_page,
              per_page: sub_storage_per_page,
              total_count: total_children,
              total_pages: (total_children.to_f / sub_storage_per_page).ceil,
              has_next_page: sub_storage_page * sub_storage_per_page < total_children,
              has_prev_page: sub_storage_page > 1
            }
          }
        end

        if include_items
          items_page = params[:items_page]&.to_i || 1
          items_per_page = 10
          items_offset = (items_page - 1) * items_per_page
          
          items = storage.items.limit(items_per_page).offset(items_offset)
          total_items = storage.items.count
          
          result[:items] = {
            data: items.map do |item|
              {
                id: item.id,
                name: item.name,
                quantity: item.quantity,
                unit: item.unit,
                min_quantity: item.min_quantity,
                out_of_stock_threshold: item.out_of_stock_threshold,
                low_stock_alert_enabled: item.low_stock_alert_enabled,
                out_of_stock_alert_enabled: item.out_of_stock_alert_enabled,
                expiration_date: item.expiration_date,
                notes: item.notes,
                image_url: item.image_url,
                low_stock: item.low_stock?,
                out_of_stock: item.out_of_stock?,
                created_at: item.created_at,
                updated_at: item.updated_at
              }
            end,
            pagination: {
              current_page: items_page,
              per_page: items_per_page,
              total_count: total_items,
              total_pages: (total_items.to_f / items_per_page).ceil,
              has_next_page: items_page * items_per_page < total_items,
              has_prev_page: items_page > 1
            }
          }
        end

        result
      end

      def render_limit_error(resource)
        render json: {
          status: { code: 403, message: 'Limit reached for current plan.' },
          errors: [current_user.limit_error_message(resource)]
        }, status: :forbidden
      end
    end
  end
end

