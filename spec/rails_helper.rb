# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
ActiveJob::Base.queue_adapter = :test
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

module JsonHelpers
  def response_json
    JSON.parse(response.body, symbolize_names: true)
  end
end

module ActiveJobMatcher
  def jobs_should_include(klass, count: nil)
    if count
      expect(job_count(klass)).to eq(count)
    else
      expect(job_count(klass)).not_to eq(0)
    end
  end

  def job_count(klass)
    ActiveJob::Base.queue_adapter.enqueued_jobs.select{ |h| h[:job] = klass }.count
  end
end

RSpec.configure do |config|
  config.include JsonHelpers, type: :controller
  config.include ActiveJobMatcher

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  OmniAuth.config.test_mode = true

  config.after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end
end
