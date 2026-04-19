class MakeGoogleUidNullableInUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :google_uid, true
  end
end
