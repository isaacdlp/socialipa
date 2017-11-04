class AddCookieToTwAccounts < ActiveRecord::Migration
  def change
    add_column :tw_accounts, :cookie, :text
  end
end
