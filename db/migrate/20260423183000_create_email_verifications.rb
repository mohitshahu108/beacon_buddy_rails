class CreateEmailVerifications < ActiveRecord::Migration[8.1]
  def change
    create_table :email_verifications do |t|
      t.string :email, null: false
      t.string :verification_token, null: false
      t.datetime :expires_at, null: false
      t.boolean :verified, default: false

      t.timestamps
    end

    add_index :email_verifications, :email, unique: true
    add_index :email_verifications, :verification_token, unique: true
    add_index :email_verifications, :expires_at
  end
end
