ENV["RAILS_ENV"] ||= "test"

DOORKEEPER_ORM = :sequel

$LOAD_PATH.unshift File.dirname(__FILE__)

require "capybara/rspec"
require "dummy/config/environment"
require "rspec/rails"
require "generator_spec/test_case"

# Doorkeeper's specs (>= 5.9) rely on Timecop, which its own Gemfile requires
# implicitly via Bundler. It's a dev dependency here, so require it explicitly.
require "timecop"

# Load JRuby SQLite3 if in that platform
begin
  require "jdbc/sqlite3"
  Jdbc::SQLite3.load_driver
rescue LoadError
end

Rails.logger.info "====> Doorkeeper.orm = #{Doorkeeper.configuration.orm.inspect}"
Rails.logger.info "====> Rails version: #{Rails.version}"
Rails.logger.info "====> Ruby version: #{RUBY_VERSION}"

require "support/orm/#{DOORKEEPER_ORM}"

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), "../")

Dir["#{File.dirname(__FILE__)}/support/{dependencies,helpers,shared}/*.rb"].each { |f| require f }
Dir["#{ENGINE_RAILS_ROOT}/doorkeeper/lib/doorkeeper/config/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec

  config.infer_base_class_for_anonymous_controllers = false

  config.include RSpec::Rails::RequestExampleGroup, type: :request

  config.before do
    Doorkeeper.configure { orm DOORKEEPER_ORM }
  end

  config.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end

  config.order = "random"
end
