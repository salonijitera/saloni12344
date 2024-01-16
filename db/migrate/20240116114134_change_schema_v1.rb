class ChangeSchemaV1 < ActiveRecord::Migration[6.0]
  def change
    create_table :users, comment: 'Stores user account information' do |t|
      t.string :email

      t.string :password_hash

      t.string :username

      t.boolean :is_email_verified

      t.timestamps null: false
    end

    create_table :email_verification_tokens, comment: 'Stores tokens for email verification process' do |t|
      t.datetime :expires_at

      t.boolean :is_used

      t.string :token

      t.timestamps null: false
    end

    add_reference :email_verification_tokens, :user, foreign_key: true
  end
end
