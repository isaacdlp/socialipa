class CreateTwUsers < ActiveRecord::Migration
  def change
    create_table :tw_users do |t|
      t.string :userid
      t.string :username
      t.string :name
      t.string :image_url
      t.text :description

      t.timestamps
    end
  end
end
