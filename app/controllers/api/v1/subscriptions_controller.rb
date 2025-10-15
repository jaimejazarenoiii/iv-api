module Api
  module V1
    class SubscriptionsController < BaseController
      before_action :authenticate_user!

      # GET /api/v1/subscription
      def show
        @subscription = current_user.subscription

        if @subscription
          render json: {
            status: { code: 200, message: 'Subscription retrieved successfully.' },
            data: {
              subscription: subscription_json(@subscription)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 404, message: 'Subscription not found.' },
            errors: ['No subscription found for this user.']
          }, status: :not_found
        end
      end

      # PATCH/PUT /api/v1/subscription
      def update
        @subscription = current_user.subscription

        if @subscription.update(subscription_params)
          render json: {
            status: { code: 200, message: 'Subscription updated successfully.' },
            data: {
              subscription: subscription_json(@subscription)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: 'Subscription could not be updated.' },
            errors: @subscription.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def subscription_params
        params.require(:subscription).permit(:plan, :expires_at)
      end

      def subscription_json(subscription)
        {
          id: subscription.id,
          plan: subscription.plan,
          pantry_limit: subscription.pantry_limit,
          started_at: subscription.started_at,
          expires_at: subscription.expires_at,
          active: subscription.active?,
          created_at: subscription.created_at,
          updated_at: subscription.updated_at
        }
      end
    end
  end
end

