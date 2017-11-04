class AddPhonesToAccounts < ActiveRecord::Migration
  def change
    add_column :tw_accounts, :phone, :string
  end
end
