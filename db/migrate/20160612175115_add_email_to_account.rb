class AddEmailToAccount < ActiveRecord::Migration
  def self.up
    add_column :tw_accounts, :email, :string
  end

  def self.down
    remove_column :tw_accounts, :email
  end
end
