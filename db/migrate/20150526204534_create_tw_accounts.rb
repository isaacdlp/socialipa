class CreateTwAccounts < ActiveRecord::Migration
  def change
    create_table :tw_accounts do |t|
      t.string :username
      t.string :password
      t.text :description

      t.timestamps
    end
  end
end
