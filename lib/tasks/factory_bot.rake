namespace :factory_bot do
  desc 'Validate all FactoryBot factories'
  task lint: :environment do
    if Rails.env.test?
      ActiveRecord::Base.connection.transaction do
        FactoryBot.lint
        raise ActiveRecord::Rollback
      end
    else
      system('bin/rake factory_bot:lint RAILS_ENV=test')
      raise if $CHILD_STATUS.exitstatus.nonzero?
    end
  end
end
