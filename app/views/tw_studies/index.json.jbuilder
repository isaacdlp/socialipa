json.array!(@tw_studies) do |tw_study|
  json.extract! tw_study, :id, :name
  json.url tw_study_url(tw_study, format: :json)
end
