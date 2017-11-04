json.array!(@tw_accounts) do |tw_account|
  json.extract! tw_account, :id, :username, :password, :description
  json.url tw_account_url(tw_account, format: :json)
end
