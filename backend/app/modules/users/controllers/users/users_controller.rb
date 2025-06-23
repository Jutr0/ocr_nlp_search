class Users::UsersController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def show
  end

  def update
    @user.update!(user_params)
    render :show, status: :ok
  end

  def create
    @user.save!
    render :show, status: :created
  end

  def destroy
    @user.destroy!
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
