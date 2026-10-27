# frozen_string_literal: true

require "doorkeeper-sequel/version"

require "doorkeeper-sequel/railtie" if defined?(::Rails)

require "doorkeeper"
require "doorkeeper/redirect_uri_validator"
require "doorkeeper/oauth/nonstandard"
require "thor/group"

require "doorkeeper-sequel/generators/concerns/migration_actions"
require "doorkeeper-sequel/generators/application_owner_generator"
require "doorkeeper-sequel/generators/migration_generator"
require "doorkeeper-sequel/generators/previous_refresh_token_generator"
require "doorkeeper-sequel/generators/confidential_applications_generator"
require "doorkeeper-sequel/generators/pkce_generator"
require "doorkeeper-sequel/generators/remove_applications_secret_not_null_constraint_generator"
require "doorkeeper-sequel/generators/polymorphic_resource_owner_generator"

require "doorkeeper-sequel/mixins/concerns/sequel_compat"
require "doorkeeper-sequel/mixins/access_token_mixin"
require "doorkeeper-sequel/mixins/access_grant_mixin"
require "doorkeeper-sequel/mixins/application_mixin"

require "doorkeeper/orm/sequel"

module DoorkeeperSequel
  def load_locales
    locales_dir = File.expand_path("../config/locales", __dir__)
    locales = Dir[File.join(locales_dir, "*.yml")]

    I18n.load_path |= locales
  end

  module_function :load_locales
end

DoorkeeperSequel.load_locales
