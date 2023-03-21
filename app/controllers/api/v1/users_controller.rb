class Api::V1::UsersController < ApplicationController
  before_action :find_user_through_email, only: %i[login]
  before_action :find_user_through_slug, only: %i[update]

  def login
    render json: { message: 'Login successful' }, status: :ok
  end

  def create
    @user = User.new(user_create_params)

    if @user.save
      render json: { message: 'User created successfully' }, status: :ok
    else
      render json: { message: 'Unable to create user' }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_update_params)
      render json: { message: 'User updated successfully' }, status: :ok
    else
      render json: { message: 'Unable to update user' }, statu: :unprocessable_entity
    end
  end

  private

  def find_user_through_email
    @user = User.find_by_email(params[:email])
    return render json: { message: 'Incorrect email or password' }, status: :unprocessable_entity if @user.nil? || !@user.valid_password?(params[:password])
  end

  def user_create_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end

  def user_update_params
    params.require(:user).permit(:first_name, :last_name)
  end

  def find_user_through_slug
    @user = User.friendly.find(params[:id])
  rescue StandardError => _e
    render json: { message: 'User not found' }, status: :unprocessable_entity
  end
end
