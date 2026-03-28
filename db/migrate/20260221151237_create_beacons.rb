class CreateBeacons < ActiveRecord::Migration[8.1]
  def change
    create_table :beacons do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users}
      t.string :title, null: false
      t.text :description
      t.integer :category, null: false
      t.integer :beacon_type, null: false
      t.integer :privacy, null: false
      t.datetime :event_time, null: false
      t.integer :max_participants, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
