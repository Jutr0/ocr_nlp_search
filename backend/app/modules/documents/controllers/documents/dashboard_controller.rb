module Documents
  class DashboardController < ApplicationController
    def show
      result = DashboardService.new(user: current_user).call
      render json: result
    end
  end
end
