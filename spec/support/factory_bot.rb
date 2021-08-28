Rails.application.load_tasks

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    Rake::Task['factory_bot:lint'].invoke
  end
end
