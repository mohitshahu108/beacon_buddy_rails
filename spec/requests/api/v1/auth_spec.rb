require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/register" do
    context "with valid params" do
      it "creates a new user and returns token" do
        post "/api/v1/auth/register", params: {
          email: "test@example.com",
          password: "Test@1234",
          name: "Test User"
        }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["token"]).to be_present
        expect(json["user"]["email"]).to eq("test@example.com")
        expect(json["user"]["name"]).to eq("Test User")
      end
    end

    context "with weak password" do
      it "returns validation error" do
        post "/api/v1/auth/register", params: {
          email: "test@example.com",
          password: "weak",
          name: "Test User"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq("registration_failed")
      end
    end

    context "with duplicate email" do
      it "returns validation error" do
        create(:user, email: "test@example.com")

        post "/api/v1/auth/register", params: {
          email: "test@example.com",
          password: "Test@1234",
          name: "Test User"
        }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq("registration_failed")
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "login@example.com") }

    context "with valid credentials" do
      it "returns token and user data" do
        post "/api/v1/auth/login", params: {
          email: "login@example.com",
          password: "Test@1234"
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["token"]).to be_present
        expect(json["user"]["email"]).to eq("login@example.com")
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized error" do
        post "/api/v1/auth/login", params: {
          email: "login@example.com",
          password: "wrongpassword"
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq("invalid_credentials")
      end
    end
  end

  describe "POST /api/v1/auth/password/reset" do
    let!(:user) { create(:user, email: "reset@example.com") }

    context "with existing email" do
      it "generates reset token" do
        post "/api/v1/auth/password/reset", params: {
          email: "reset@example.com"
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["token"]).to be_present
      end
    end

    context "with non-existing email" do
      it "returns success message to prevent enumeration" do
        post "/api/v1/auth/password/reset", params: {
          email: "nonexistent@example.com"
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to be_present
      end
    end
  end

  describe "POST /api/v1/auth/password/confirm" do
    let!(:user) { create(:user, email: "confirm@example.com") }

    context "with valid token" do
      it "resets password successfully" do
        token = user.generate_password_reset_token

        post "/api/v1/auth/password/confirm", params: {
          email: "confirm@example.com",
          token: token,
          new_password: "NewPass@1234"
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Password reset successfully")

        # Verify password was changed
        expect(user.reload.authenticate("NewPass@1234")).to be_truthy
      end
    end

    context "with invalid token" do
      it "returns unauthorized error" do
        post "/api/v1/auth/password/confirm", params: {
          email: "confirm@example.com",
          token: "invalid_token",
          new_password: "NewPass@1234"
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq("invalid_token")
      end
    end
  end

  describe "POST /api/v1/auth/link_password" do
    let!(:user) { create(:user, :with_google, email: "test@example.com") }
    let(:token) { JwtService.encode(user_id: user.id) }

    context "with valid password" do
      it "links password to Google account" do
        post "/api/v1/auth/link_password",
          params: { password: "Test@1234" },
          headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Password linked successfully")

        # Verify password was set
        expect(user.reload.authenticate("Test@1234")).to be_truthy
      end
    end

    context "with weak password" do
      it "returns validation error" do
        post "/api/v1/auth/link_password",
          params: { password: "weak" },
          headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq("password_link_failed")
      end
    end
  end
end
