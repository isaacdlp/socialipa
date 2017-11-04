class RenameAccountToStudyId < ActiveRecord::Migration
  def change
    rename_column :tw_stats, :tw_account_id, :tw_study_id
  end
end
