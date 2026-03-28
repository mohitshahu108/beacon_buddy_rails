class CreateBeaconParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :beacon_participants do |t|
      t.references :beacon, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
