class TwAccount < ActiveRecord::Base
  before_save { |blob| blob.username = blob.username.downcase }
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true
end
