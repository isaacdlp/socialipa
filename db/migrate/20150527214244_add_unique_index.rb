class AddUniqueIndex < ActiveRecord::Migration
  def change
    add_index :tw_list_items, [:tw_list_id, :item], unique: true
  end
end
