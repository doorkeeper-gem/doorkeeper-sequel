# frozen_string_literal: true

module Doorkeeper
  module Orm
    module Sequel
      class StaleRecordsCleaner
        def initialize(base_scope)
          @base_scope = base_scope
        end

        def clean_revoked
          @base_scope
            .where(::Sequel.~(revoked_at: nil))
            .where { revoked_at < Time.current }
            .delete
        end

        def clean_expired(ttl)
          now = Time.current
          model = @base_scope.respond_to?(:model) ? @base_scope.model : @base_scope

          scope = @base_scope
            .exclude(expires_in: nil)
            .where { created_at < (now - ttl) }

          if model.supports_expiration_time_math?
            elapsed = model.seconds_since_created_sql(now)
            scope = scope.where { elapsed > :expires_in }
          else
            ::Kernel.warn(::Doorkeeper::Models::ExpirationTimeSqlMath::WARNING_MESSAGE)
          end

          scope.delete
        end
      end
    end
  end
end
