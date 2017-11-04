class CreateTwLists < ActiveRecord::Migration
  def change
    create_table :tw_lists do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
