module Api
  module V1
    class BaseController < ApplicationController
      # This will be inherited by all API v1 controllers
      respond_to :json
    end
  end
end

