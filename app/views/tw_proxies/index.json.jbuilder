json.array!(@tw_proxies) do |tw_proxy|
  json.extract! tw_proxy, :id, :host, :port, :username, :password
  json.url tw_proxy_url(tw_proxy, format: :json)
end
