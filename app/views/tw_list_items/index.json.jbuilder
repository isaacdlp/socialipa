json.array!(@tw_list_items) do |tw_list_item|
  json.extract! tw_list_item, :id, :tw_list_id, :item
  json.url tw_list_item_url(tw_list_item, format: :json)
end
