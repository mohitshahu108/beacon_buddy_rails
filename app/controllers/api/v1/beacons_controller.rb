module Api
    module V1
        class BeaconsController < ApplicationController
            before_action :authenticate_user!
            before_action :set_beacon, only: [ :show, :update, :destroy, :join ]

            # POST api/v1/beacons
            def create
                beacon = current_user.created_beacons.new(beacon_params)

                if beacon.save
                    # auto-add creator as joined participant
                    beacon.beacon_participants.create!(user: current_user, status: :joined)
                    render json: beacon, status: :created
                else
                    render json: { errors: beacon.errors.full_messages }, status: :unprocessable_entity
                end
            end

            # GET api/v1/beacons/:id
            def show
                render json: @beacon
            end

            # PATCH api/v1/beacons/:id
            def update
                @beacon.update(beacon_params)
                render json: @beacon
            end

            # DELETE api/v1/beacons/:id
            def destroy
                @beacon.destroy
                render json: { message: "Beacon deleted" }
            end

            # POST api/v1/beacons/:id/join
            def join
                # Global Guards
                if @beacon.creator == current_user
                    return render json: { error: "Creator cannot join their own beacon" }, status: :unprocessable_entity
                end

                if @beacon.event_time.past?
                    return render json: { error: "Cannot join past beacon" }, status: :unprocessable_entity
                end

                if @beacon.joined_count >= beacon.max_participants
                    return render json: { error: "Beacon is full" }, status: :unprocessable_entity
                end

                existing = @beacon.beacon_participants.find_by(user: current_user)
                if existing.present? && !existing.left?
                    return render json: { error: "Already requested or joined" }, status: :unprocessable_entity
                end

                if existing.rejected?
                    return render json: { error: "Request was rejected" }, status: :unprocessable_entity
                end

                # Handle rejoin if user left previously
                if existing&.left?
                    participant = existing
                    # Reset status based on policy
                    participant.status = @beacon.open? ? :joined : :pending
                    participant.save!
                    return render json: { message: "Request submitted" }, status: :ok
                end

                # Branch by join_policy
                status_to_set = case @beacon.join_policy
                when "open"
                    :joined
                when "personal"
                    :pending
                when "filtered"
                    # For now, assume passed; actual filter logic in next iteration
                    :joined
                end

                @beacon.beacon_participants.create!(user: current_user, status: status_to_set)

                render json: { message: "Request submitted" }, status: :created
            end

            private

            def set_beacon
                @beacon = Beacon.find params[:id]
            end


            def beacon_params
                params.required(:beacon).permit(
                    :id,
                    :title,
                    :description,
                    :category,
                    :beacon_type,
                    :privacy,
                    :event_time,
                    :max_participants
                )
            end
        end
    end
end
