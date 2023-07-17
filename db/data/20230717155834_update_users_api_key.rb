# frozen_string_literal: true

class UpdateUsersApiKey < ActiveRecord::Migration[7.0]
  def up
    @users = User.where(api_key: nil)
    @users.each do |user|
      user.update! api_key: SecureRandom.urlsafe_base64
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
