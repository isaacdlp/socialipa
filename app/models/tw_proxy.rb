class TwProxy < ActiveRecord::Base
  validates :nickname, presence: true, uniqueness: true
end
