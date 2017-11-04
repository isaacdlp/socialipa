class TwList < ActiveRecord::Base
  has_many :tw_list_items, dependent: :destroy
  validates :name, presence: true, uniqueness: true

  def self.get_or_create(list_name)
    list = TwList.find_by_name(list_name)
    unless list
      list = TwList.new(name: list_name)
      list.save
    end
    list
  end

  def self.item_array(list_name)
    list = find_by_name(list_name)
    return nil unless list
    list.item_array
  end

  def item_array
    items = []
    tw_list_items.each do |line|
      items.push line.item
    end
    items
  end

  def lines
    tw_list_items
  end

  def include?(item)
    tw_list_items.find_by_item(item)
  end

  def add(item)
    unless include? item
      return tw_list_items.build({item: item}).save
    end
    nil
  end

end
