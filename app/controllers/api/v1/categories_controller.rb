module Api
  module V1
    class CategoriesController < BaseController
      before_action :authenticate_user!
      before_action :set_category, only: [:show, :update, :destroy]

      # GET /api/v1/categories
      def index
        @categories = current_user.categories.includes(:items)

        render json: {
          status: { code: 200, message: 'Categories retrieved successfully.' },
          data: {
            categories: @categories.map { |category| category_json(category) }
          }
        }, status: :ok
      end

      # GET /api/v1/categories/:id
      def show
        render json: {
          status: { code: 200, message: 'Category retrieved successfully.' },
          data: {
            category: category_json(@category, include_items: true)
          }
        }, status: :ok
      end

      # POST /api/v1/categories
      def create
        @category = current_user.categories.build(category_params)

        if @category.save
          render json: {
            status: { code: 201, message: 'Category created successfully.' },
            data: {
              category: category_json(@category)
            }
          }, status: :created
        else
          render json: {
            status: { code: 422, message: 'Category could not be created.' },
            errors: @category.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/categories/:id
      def update
        if @category.update(category_params)
          render json: {
            status: { code: 200, message: 'Category updated successfully.' },
            data: {
              category: category_json(@category)
            }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: 'Category could not be updated.' },
            errors: @category.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/categories/:id
      def destroy
        @category.destroy
        render json: {
          status: { code: 200, message: 'Category deleted successfully.' }
        }, status: :ok
      end

      private

      def set_category
        @category = current_user.categories.find_by(id: params[:id])
        unless @category
          render json: {
            status: { code: 404, message: 'Category not found.' },
            errors: ['Category does not exist or you do not have permission to access it.']
          }, status: :not_found
        end
      end

      def category_params
        params.require(:category).permit(:name)
      end

      def category_json(category, include_items: false)
        result = {
          id: category.id,
          name: category.name,
          items_count: category.items.count,
          created_at: category.created_at,
          updated_at: category.updated_at
        }

        if include_items
          result[:items] = category.items.map do |item|
            {
              id: item.id,
              name: item.name,
              storage_id: item.storage_id,
              storage_name: item.storage.name,
              quantity: item.quantity,
              unit: item.unit
            }
          end
        end

        result
      end
    end
  end
end

