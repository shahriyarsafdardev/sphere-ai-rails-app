# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params['token']}"
    response = HTTParty.get(url)
    @user = User.from_omniauth(response.parsed_response)
    if @user
      render json: { message: 'user was successfully logged in!', user: @user }, status: :created
    else
      render json: { message: 'There was a problem signing you in!' }, status: :unprocessable_entity
    end
  end
end
