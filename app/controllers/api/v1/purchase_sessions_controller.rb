module Api
  module V1
    class PurchaseSessionsController < BaseController
      before_action :authenticate_user!
      before_action :set_purchase_session, only: [:show, :update, :destroy]

      # GET /api/v1/purchase_sessions
      def index
        @purchase_sessions = current_user.purchase_sessions
          .includes(:purchase_items, :items)
          .order(purchased_at: :desc)

        render json: {
          status: { code: 200, message: 'Purchase sessions retrieved successfully.' },
          data: {
            purchase_sessions: @purchase_sessions.map { |ps| purchase_session_json(ps) }
          }
        }, status: :ok
      end

      # GET /api/v1/purchase_sessions/:id
      def show
        render json: {
          status: { code: 200, message: 'Purchase session retrieved successfully.' },
          data: {
            purchase_session: purchase_session_json(@purchase_session, include_items: true)
          }
        }, status: :ok
      end

      # POST /api/v1/purchase_sessions
      def create
        @purchase_session = current_user.purchase_sessions.build(purchase_session_params)

        if @purchase_session.save
          # Create purchase items if provided
          if params[:purchase_items].present?
            create_purchase_items(@purchase_session, params[:purchase_items])
          end

          render json: {
            status: { code: 201, message: 'Purchase session created successfully.' },
            data: {
              purchase_session: purchase_session_json(@purchase_session, include_items: true)
            }
          }, status: :created
        else
          render json: {
            status: { code: 422, message: 'Purchase session could not be created.' },
            errors: @purchase_session.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/purchase_sessions/:id
      def update
        if @purchase_session.update(purchase_session_params)
          render json: {
            status: { code: 200, message: 'Purchase session updated successfully.' },
            data: {
              purchase_session: purchase_session_json(@purchase_session)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: 'Purchase session could not be updated.' },
            errors: @purchase_session.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/purchase_sessions/:id
      def destroy
        @purchase_session.destroy
        render json: {
          status: { code: 200, message: 'Purchase session deleted successfully.' }
        }, status: :ok
      end

      private

      def set_purchase_session
        @purchase_session = current_user.purchase_sessions.find_by(id: params[:id])
        unless @purchase_session
          render json: {
            status: { code: 404, message: 'Purchase session not found.' },
            errors: ['Purchase session does not exist or you do not have permission to access it.']
          }, status: :not_found
        end
      end

      def purchase_session_params
        params.require(:purchase_session).permit(:store_name, :total_amount, :purchased_at, :notes)
      end

      def create_purchase_items(purchase_session, items_params)
        items_params.each do |item_params|
          purchase_session.purchase_items.create!(
            item_id: item_params[:item_id],
            quantity: item_params[:quantity],
            unit_price: item_params[:unit_price]
          )
        end
      end

      def purchase_session_json(purchase_session, include_items: false)
        result = {
          id: purchase_session.id,
          store_name: purchase_session.store_name,
          total_amount: purchase_session.total_amount,
          purchased_at: purchase_session.purchased_at,
          notes: purchase_session.notes,
          items_count: purchase_session.purchase_items.count,
          created_at: purchase_session.created_at,
          updated_at: purchase_session.updated_at
        }

        if include_items
          result[:items] = purchase_session.purchase_items.includes(:item).map do |pi|
            {
              id: pi.id,
              item_id: pi.item_id,
              item_name: pi.item.name,
              quantity: pi.quantity,
              unit_price: pi.unit_price,
              total_price: pi.total_price
            }
          end
        end

        result
      end
    end
  end
end

