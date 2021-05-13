Rails.application.configure do
  # rubocop:disable Style/ConditionalAssignment
  if !Rails.env.development? || ENV['LOGRAGE_IN_DEVELOPMENT'] == 'true'
    config.lograge.enabled = true
  else
    config.lograge.enabled = false
  end
  # rubocop:enable Style/ConditionalAssignment
end
