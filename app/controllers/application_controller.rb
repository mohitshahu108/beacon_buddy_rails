class ApplicationController < ActionController::API
  attr_reader :current_user

  def authenticate_user!
    header = request.headers["Authorization"]
    if header.present?
      token = header.split(" ").last
      decoded = JwtService.decode(token)
      if decoded
        @current_user = User.find_by(id: decoded[:user_id])
      end
    end

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
