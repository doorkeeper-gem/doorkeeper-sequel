# frozen_string_literal: true

module Doorkeeper
  class AccessToken < Sequel::Model(:oauth_access_tokens)
    include DoorkeeperSequel::AccessTokenMixin

    class << self
      def refresh_token_revoked_on_use?
        columns.include?(:previous_refresh_token)
      end

      def polymorphic_resource_owner?
        columns.include?(:resource_owner_type)
      end
    end
  end
end
