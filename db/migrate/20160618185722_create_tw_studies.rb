class CreateTwStudies < ActiveRecord::Migration
  def change
    create_table :tw_studies do |t|
      t.string :name

      t.timestamps
    end
  end
end
