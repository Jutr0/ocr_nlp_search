class SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  private

  def respond_with(resource, _opts = {})
    render json: { user: resource }, status: :ok
  end

  def respond_to_on_destroy
    head :no_content
  end
end
