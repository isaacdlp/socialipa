json.array!(@tw_lists) do |tw_list|
  json.extract! tw_list, :id, :name, :description
  json.url tw_list_url(tw_list, format: :json)
end
