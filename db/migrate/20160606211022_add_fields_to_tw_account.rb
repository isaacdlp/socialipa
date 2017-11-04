class AddFieldsToTwAccount < ActiveRecord::Migration
  def self.up
    add_column :tw_accounts, :agent, :string
    add_column :tw_accounts, :proxy, :string
  end

  def self.down
    remove_column :tw_accounts, :agent
    remove_column :tw_accounts, :proxy
  end
end
