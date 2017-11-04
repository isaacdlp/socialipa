class CreateTwStats < ActiveRecord::Migration
  def change
    create_table :tw_stats do |t|
      t.integer :tw_account_id
      t.string :concept
      t.decimal :value

      t.timestamps
    end

    add_index :tw_stats, [:tw_account_id, :concept], unique: true
  end
end
