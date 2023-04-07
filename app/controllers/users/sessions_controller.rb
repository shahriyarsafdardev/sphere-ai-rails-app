# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(_resource, _opts = {})
      render json: current_user, message: 'Logged in successfully!', status: :ok
    end

    def respond_to_on_destroy
      current_user ? log_out_success : log_out_failure
    end

    def log_out_success
      render json: { message: 'Logged out successfully!' }, status: :ok
    end

    def log_out_failure
      render json: { message: 'Logged out failure!' }, status: :unauthorized
    end
  end
end