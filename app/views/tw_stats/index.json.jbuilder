json.array!(@tw_stats) do |tw_stat|
  json.extract! tw_stat, :id, :tw_account_id, :concept, :value
  json.url tw_stat_url(tw_stat, format: :json)
end
