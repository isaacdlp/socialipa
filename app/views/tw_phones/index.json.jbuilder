json.array!(@tw_phones) do |tw_phone|
  json.extract! tw_phone, :id, :name, :code, :number
  json.url tw_phone_url(tw_phone, format: :json)
end
