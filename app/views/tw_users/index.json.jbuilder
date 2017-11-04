json.array!(@tw_users) do |tw_user|
  json.extract! tw_user, :id, :userid, :username, :name, :image_url, :description
  json.url tw_user_url(tw_user, format: :json)
end
