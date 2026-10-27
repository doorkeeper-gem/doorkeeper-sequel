# frozen_string_literal: true

module DoorkeeperSequel
  module AccessGrantMixin
    extend ActiveSupport::Concern

    include SequelCompat
    include Doorkeeper::OAuth::Helpers
    include Doorkeeper::Models::Expirable
    include Doorkeeper::Models::Revocable
    include Doorkeeper::Models::Accessible
    include Doorkeeper::Models::SecretStorable
    include Doorkeeper::Models::Scopes

    included do
      plugin :validation_helpers
      plugin :timestamps
      many_to_one :application, class: "Doorkeeper::Application"

      set_allowed_columns :resource_owner_id, :resource_owner_type, :application_id,
                          :expires_in, :redirect_uri, :scopes, :code_challenge, :code_challenge_method,
                          :token, :resource, :access_token_id

      def before_validation
        generate_token if new?
        super
      end

      def validate
        super
        validates_presence %i[resource_owner_id application_id
                              token expires_in redirect_uri]
        validates_unique [:token]
      end
    end

    module ClassMethods
      def by_token(token)
        find_by_plaintext_token(:token, token)
      end

      def find_by(params)
        first(params)
      end

      def revoke_all_for(application_id, resource_owner, clock = Time)
        with_primary_role do
          where(application_id: application_id,
                resource_owner_id: resource_owner.id,
                revoked_at: nil)
            .update(revoked_at: clock.now.utc)
        end
      end

      def generate_code_challenge(code_verifier)
        padded_result = Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier))
        padded_result.split("=")[0] # Remove any trailing '='
      end

      def pkce_supported?
        new.pkce_supported?
      end

      # RFC 8707: resource indicators are supported only when the `resource`
      # column exists (added by the `doorkeeper:resource_indicators` generator).
      def resource_indicators_supported?
        column_names.include?("resource")
      end

      # Authorization-code replay revocation (RFC 6749 §4.1.2, §10.5) is
      # active only when the `access_token_id` column exists (added by the
      # `doorkeeper:grant_reuse_revocation` generator).
      def access_token_revoked_on_reuse?
        column_names.include?("access_token_id")
      end

      def secret_strategy
        ::Doorkeeper.configuration.token_secret_strategy
      end

      def fallback_secret_strategy
        ::Doorkeeper.configuration.token_secret_fallback_strategy
      end
    end

    private

    # Generates token value with UniqueToken class.
    #
    # @return [String] token value
    #
    def generate_token
      return nil unless self[:token].nil?

      @raw_token = UniqueToken.generate
      secret_strategy.store_secret(self, :token, @raw_token)
    end
  end
end
