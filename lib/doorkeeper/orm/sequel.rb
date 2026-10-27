# frozen_string_literal: true

require "doorkeeper/orm/sequel/stale_records_cleaner"

module Doorkeeper
  module Orm
    module Sequel
      # Modern Doorkeeper (>= 5.6.4) ORM entry point. Older versions call
      # #initialize_models! / #initialize_application_owner! directly, which we
      # keep below for backwards compatibility; newer versions call #run_hooks
      # and warn if it's missing. We funnel both paths through the same logic.
      def self.run_hooks
        initialize_models!
        initialize_application_owner!
      end

      def self.initialize_models!
        # Hack to bypass Sequel restrictions to model datasets definition.
        # As it requires valid existing table at the moment of Model class definition,
        # all the rake tasks (db:create, db:migrate, etc) would be aborted due to error.
        old_value = ::Sequel::Model.require_valid_table
        ::Sequel::Model.require_valid_table = false
        ::Sequel::Model.strict_param_setting = false
        ::Sequel::Model.plugin :json_serializer
        ::Sequel::Model.plugin :polymorphic

        # Store and read timestamps as UTC so expiration math stays correct
        # regardless of the host application's system timezone. Doorkeeper
        # works entirely in UTC (e.g. #generate_token sets created_at to
        # Time.now.utc); without this Sequel would reinterpret naive datetime
        # columns in the local zone on read.
        ::Sequel.default_timezone = :utc

        # `Sequel.date_add` (used for expiration-time math when matching and
        # cleaning tokens) lives in the date_arithmetic extension.
        ::Sequel.extension :date_arithmetic

        begin
          require "doorkeeper/orm/sequel/access_grant"
          require "doorkeeper/orm/sequel/access_token"
          require "doorkeeper/orm/sequel/application"
        ensure
          ::Sequel::Model.require_valid_table = old_value
        end
      end

      def self.initialize_application_owner!
        return unless Doorkeeper.config.enable_application_owner?

        require "doorkeeper-sequel/mixins/concerns/ownership"

        Doorkeeper::Application.send :include, DoorkeeperSequel::Ownership
      end
    end
  end
end
