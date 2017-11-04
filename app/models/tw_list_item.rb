class TwListItem < ActiveRecord::Base
  before_save { |blob| blob.item = blob.item.downcase }
  belongs_to :tw_list
  validates :tw_list_id, presence: true
  validates :item, presence: true
end
