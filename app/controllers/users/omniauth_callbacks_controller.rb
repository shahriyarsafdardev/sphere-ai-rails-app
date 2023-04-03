# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params['token']}"
    responsee = HTTParty.get(url)
    @user = User.from_omniauth(responsee.parsed_response)
    if @user && sign_in(@user)
      response.headers['Authorization'] = "Bearer #{generate_custom_devise_token(@user)}"
      render json: { message: 'user was successfully logged in!', user: @user }, status: :created
    else
      render json: { message: 'There was a problem signing you in!' }, status: :unprocessable_entity
    end
  end

  private

  def generate_custom_devise_token(user)
    jti = SecureRandom.uuid
    exp_time = (Time.zone.now + 1.week).to_time.to_i
    JWT.encode({ sub: user.id, jti: jti, exp: exp_time, scp: 'user' }, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
  end
end
