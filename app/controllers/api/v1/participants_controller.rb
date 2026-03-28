module Api
  module V1
    class ParticipantsController < ApplicationController
      before_action :set_beacon
      before_action :set_participant
      before_action :authorize_creator!

      def approve
        return render_error("Beacon must be personal", 422) unless @beacon.personal?
        return render_error("Beacon is not active", 422) unless @beacon.active?
        return render_error("Event has already passed", 422) if @beacon.event_date.past?
        return render_error("Participant is not pending", 422) unless @participant.pending?
        return render_error("Beacon is full", 422) if beacon_full?

        @participant.update!(status: :approved)

        render json: @participant, status: :ok
      end

      def reject
        return render_error("Participant is not pending", 422) unless @participant.pending?

        @participant.update!(status: :rejected)

        render json: @participant, status: :ok
      end

      private

      def set_beacon
        @beacon = Beacon.find(params[:beacon_id])
      end

      def set_participant
        @participant = @beacon.beacon_participants.find(params[:id])
      end

      def authorize_creator!
        return if @beacon.creator_id == current_user.id

        render_error("Not authorized", 403)
      end

      def beacon_full?
        @beacon.beacon_participants.approved.count >= @beacon.max_participants
      end

      def render_error(message, status)
        render json: { error: message }, status: status
      end
    end
  end
end
