class AddPositionToLists < ActiveRecord::Migration
  def self.up
    add_column :tw_lists, :position, :integer
  end

  def self.down
    remove_column :tw_lists, :position
  end
end
