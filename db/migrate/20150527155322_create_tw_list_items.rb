class CreateTwListItems < ActiveRecord::Migration
  def change
    create_table :tw_list_items do |t|
      t.integer :tw_list_id
      t.string :item

      t.timestamps
    end
  end
end
