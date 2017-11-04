class AddStatusToAccounts < ActiveRecord::Migration
  def change
    add_column :tw_accounts, :status, :string, default: :ok
  end
end
