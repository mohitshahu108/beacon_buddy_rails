require "google-id-token"

module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_user!, only: [ :me, :link_password ]

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

      def register
        user = User.new(email: params[:email], password: params[:password], name: params[:name])

        if user.save
          token = JwtService.encode(user_id: user.id)
          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name
            }
          }, status: :created
        else
          render json: {
            error: {
              code: "registration_failed",
              message: "Registration failed",
              details: user.errors.full_messages
            }
          }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = JwtService.encode(user_id: user.id)
          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name
            }
          }
        else
          render json: {
            error: {
              code: "invalid_credentials",
              message: "Invalid email or password"
            }
          }, status: :unauthorized
        end
      end

      def password_reset
        user = User.find_by(email: params[:email])

        if user
          token = user.generate_password_reset_token
          # In production, you would send this token via email
          # For now, we return it in the response for testing
          render json: {
            message: "Password reset token generated",
            token: token
          }
        else
          # Always return success to prevent email enumeration
          render json: {
            message: "If the email exists, a reset token has been sent"
          }
        end
      end

      def password_confirm
        user = User.find_by(email: params[:email])

        if user&.valid_password_reset_token?(params[:token])
          if user.update(password: params[:new_password])
            render json: {
              message: "Password reset successfully"
            }
          else
            render json: {
              error: {
                code: "password_update_failed",
                message: "Failed to update password",
                details: user.errors.full_messages
              }
            }, status: :unprocessable_entity
          end
        else
          render json: {
            error: {
              code: "invalid_token",
              message: "Invalid or expired reset token"
            }
          }, status: :unauthorized
        end
      end

      def link_password
        if current_user.update(password: params[:password])
          render json: {
            message: "Password linked successfully"
          }
        else
          render json: {
            error: {
              code: "password_link_failed",
              message: "Failed to link password",
              details: current_user.errors.full_messages
            }
          }, status: :unprocessable_entity
        end
      end

      def me
        render json: current_user
      end
    end
  end
end
