class ChangePasswordDigestToEmail < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :password_digest, :email
  end
end
