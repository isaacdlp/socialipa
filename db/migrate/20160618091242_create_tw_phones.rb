class CreateTwPhones < ActiveRecord::Migration
  def change
    create_table :tw_phones do |t|
      t.string :nickname
      t.string :code
      t.string :number

      t.timestamps
    end
  end
end
