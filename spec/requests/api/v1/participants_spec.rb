require 'rails_helper'

RSpec.describe "Participants Approval", type: :request do
  let(:creator) { create(:user) }
  let(:participant_user) { create(:user) }
  let(:beacon) { create(:beacon, creator: creator) }
  let(:participant) do
    create(:beacon_participant,
      beacon: beacon,
      user: participant_user,
      status: :pending
    )
  end

  describe "PATCH /api/v1/beacons/:beacon_id/participants/:id/approve" do
    context "when creator approves pending participant" do
      before do
        sign_in creator
        patch "/api/v1/beacons/#{beacon.id}/participants/#{participant.id}/approve"
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates status to approved" do
        expect(participant.reload.status).to eq("approved")
      end
    end

    context "when non-creator tries to approve" do
      before do
        sign_in participant_user
        patch "/api/v1/beacons/#{beacon.id}/participants/#{participant.id}/approve"
      end

      it "returns 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
