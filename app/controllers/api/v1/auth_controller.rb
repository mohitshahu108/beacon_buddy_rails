require "google-id-token"

module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_user!, only: [ :me ]

      def google
        validator = GoogleIDToken::Validator.new

        payload = validator.check(
          params[:id_token],
          ENV["GOOGLE_WEB_CLIENT_ID"]
        )

        user = User.find_or_create_by!(google_uid: payload["sub"]) do |u|
          u.email = payload["email"]
          u.name  = payload["name"]
        end

        token = JwtService.encode(user_id: user.id)

        render json: {
          token: token,
          user: {
            id: user.id,
            email: user.email,
            name: user.name
          }
        }
      rescue GoogleIDToken::ValidationError
        render json: {
          error: {
            code: "invalid_google_token",
            message: "Google token is invalid"
          }
        }, status: :unauthorized
      end

    def me
        render json: current_user
    end
    end
  end
end
