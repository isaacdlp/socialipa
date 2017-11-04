class TwStat < ActiveRecord::Base
  belongs_to :tw_study
  validates :tw_study_id, presence: true
  validates :concept, presence: true
  validates :value, presence: true
end
