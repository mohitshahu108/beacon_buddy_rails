class RenamePrivacyToJoinPolicyInBeacons < ActiveRecord::Migration[8.1]
  def change
    rename_column :beacons, :privacy, :join_policy
  end
end
