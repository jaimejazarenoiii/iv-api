module Api
  module V1
    class ItemsController < BaseController
      before_action :authenticate_user!
      before_action :set_item, only: [:show, :update, :destroy]

      # GET /api/v1/items
      def index
        @items = current_user.items.includes(:storage, :purchase_items)

        # Optional filter by storage_id
        @items = @items.where(storage_id: params[:storage_id]) if params[:storage_id].present?

        render json: {
          status: { code: 200, message: 'Items retrieved successfully.' },
          data: {
            items: @items.map { |item| item_json(item) }
          }
        }, status: :ok
      end

      # GET /api/v1/items/low_stock
      def low_stock
        @items = current_user.items.includes(:storage).select { |item| item.low_stock? }

        render json: {
          status: { code: 200, message: 'Low stock items retrieved successfully.' },
          data: {
            items: @items.map { |item| item_json(item) }
          }
        }, status: :ok
      end

      # GET /api/v1/items/out_of_stock
      def out_of_stock
        @items = current_user.items.includes(:storage).select { |item| item.out_of_stock? }

        render json: {
          status: { code: 200, message: 'Out of stock items retrieved successfully.' },
          data: {
            items: @items.map { |item| item_json(item) }
          }
        }, status: :ok
      end

      # GET /api/v1/items/:id
      def show
        render json: {
          status: { code: 200, message: 'Item retrieved successfully.' },
          data: {
            item: item_json(@item)
          }
        }, status: :ok
      end

      # POST /api/v1/items
      def create
        @item = current_user.items.build(item_params)

        if @item.save
          render json: {
            status: { code: 201, message: 'Item created successfully.' },
            data: {
              item: item_json(@item)
            }
          }, status: :created
        else
          render json: {
            status: { code: 422, message: 'Item could not be created.' },
            errors: @item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/items/:id
      def update
        if @item.update(item_params)
          render json: {
            status: { code: 200, message: 'Item updated successfully.' },
            data: {
              item: item_json(@item)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: 'Item could not be updated.' },
            errors: @item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/items/:id
      def destroy
        @item.destroy
        render json: {
          status: { code: 200, message: 'Item deleted successfully.' }
        }, status: :ok
      end

      # DELETE /api/v1/items/:id/image
      def destroy_image
        if @item.image.attached?
          @item.image.purge
          render json: {
            status: { code: 200, message: 'Item image deleted successfully.' },
            data: {
              item: item_json(@item)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 404, message: 'No item image found.' },
            errors: ['No item image to delete.']
          }, status: :not_found
        end
      end

      private

      def set_item
        @item = current_user.items.find_by(id: params[:id])
        unless @item
          render json: {
            status: { code: 404, message: 'Item not found.' },
            errors: ['Item does not exist or you do not have permission to access it.']
          }, status: :not_found
        end
      end

      def item_params
        params.require(:item).permit(:name, :quantity, :unit, :min_quantity, :expiration_date, :notes, :storage_id, :out_of_stock_threshold, :low_stock_alert_enabled, :out_of_stock_alert_enabled, :image)
      end

      def item_json(item)
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
          storage_id: item.storage_id,
          storage_name: item.storage.name,
          image_url: item.image_url,
          location_path: item.location_path,
          location_array: item.location_array,
          low_stock: item.low_stock?,
          out_of_stock: item.out_of_stock?,
          created_at: item.created_at,
          updated_at: item.updated_at
        }
      end
    end
  end
end

