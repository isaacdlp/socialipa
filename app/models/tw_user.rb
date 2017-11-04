class TwUser < ActiveRecord::Base
  before_save { |user| user.username = user.username.downcase }
  validates :userid, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
end
