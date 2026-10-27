# frozen_string_literal: true

module DoorkeeperSequel
  module AccessTokenMixin
    extend ActiveSupport::Concern

    include SequelCompat
    include Doorkeeper::OAuth::Helpers
    include Doorkeeper::Models::Revocable
    include Doorkeeper::Models::Expirable
    include Doorkeeper::Models::Reusable
    include Doorkeeper::Models::Accessible
    include Doorkeeper::Models::SecretStorable
    include Doorkeeper::Models::Scopes
    include Doorkeeper::Models::ResourceOwnerable

    included do
      plugin :validation_helpers
      plugin :timestamps


      many_to_one :application, class: "Doorkeeper::Application"
      many_to_one :resource_owner, polymorphic: true

      attr_writer :use_refresh_token

      set_allowed_columns :application_id, :resource_owner_id, :resource_owner_type,
                                           :expires_in, :scopes, :use_refresh_token, 
                                           :previous_refresh_token, :token, :refresh_token

      def before_validation
        if new?
          generate_token
          generate_refresh_token if use_refresh_token?
        end

        super
      end

      def validate
        super
        validates_presence [:token]
        validates_unique [:token]

        validates_unique [:refresh_token] if use_refresh_token?
      end

      def application_id?
        application_id.present?
      end
    end

    module ClassMethods
      def by_token(token)
        find_by_plaintext_token(:token, token)
      end

      def find_by(params)
        first(params)
      end

      def by_refresh_token(refresh_token)
        find_by_plaintext_token(:refresh_token, refresh_token)
      end

      # Returns non-revoked access tokens for the given resource owner.
      def active_for(resource_owner)
        by_resource_owner(resource_owner).where(revoked_at: nil)
      end

      # Returns non-revoked and non-expired access tokens. A token with a
      # NULL expires_in never expires.
      def not_expired
        where(revoked_at: nil).where(not_expired_condition)
      end

      def revoke_all_for(application_id, resource_owner, clock = Time)
        with_primary_role do
          by_resource_owner(resource_owner)
            .where(application_id: application_id, revoked_at: nil)
            .update(revoked_at: clock.now.utc)
        end
      end

      def by_previous_refresh_token(previous_refresh_token)
        where(refresh_token: previous_refresh_token).first
      end

      def matching_token_for(application, resource_owner_or_id, scopes, custom_attributes: nil, include_expired: true)
        resource_owner_id = if resource_owner_or_id.respond_to?(:to_key)
                              resource_owner_or_id.id
                            else
                              resource_owner_or_id
                            end
        tokens = authorized_tokens_for(application.try(:id), resource_owner_id)
        tokens = tokens.where(not_expired_condition) unless include_expired
        find_matching_token(tokens, application, custom_attributes, scopes)
      end

      def find_matching_token(relation, application, custom_attributes, scopes)
        return nil unless relation

        tokens = relation.all.select do |token|
          scopes_match?(token.scopes, scopes, application.try(:scopes)) &&
            custom_attributes_match?(token, custom_attributes)
        end

        tokens.max_by(&:created_at)
      end

      def scopes_match?(token_scopes, param_scopes, app_scopes)
        return true if token_scopes.empty? && param_scopes.empty?

        (token_scopes.sort == param_scopes.sort) &&
          Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(
            scope_str: param_scopes.to_s,
            server_scopes: Doorkeeper.configuration.scopes,
            app_scopes: app_scopes
          )
      end

      # Checks whether the token's custom attribute values match those
      # given in +custom_attributes+. A nil value ignores custom attributes.
      def custom_attributes_match?(token, custom_attributes)
        return true if custom_attributes.nil?

        token_attribs = token.custom_attributes
        return true if token_attribs.blank? && custom_attributes.blank?

        Doorkeeper.config.custom_access_token_attributes.all? do |attribute|
          token_attribs[attribute] == custom_attributes[attribute]
        end
      end

      def authorized_tokens_for(application_id, resource_owner)
        by_resource_owner(resource_owner).where(application_id: application_id,
              revoked_at: nil).order(Sequel.desc(:created_at))
      end

      def find_or_create_for(application:, resource_owner:, scopes:, **token_attributes)
        if Doorkeeper.configuration.reuse_access_token
          # nil ignores custom attributes when matching, an empty hash only
          # matches tokens that have no custom attributes set.
          custom_attributes = extract_custom_attributes(token_attributes)
          access_token = matching_token_for(
            application, resource_owner, scopes,
            custom_attributes: custom_attributes, include_expired: false
          )
          return access_token if access_token&.reusable?
        end

        create_for(
          application: application,
          resource_owner: resource_owner,
          scopes: scopes,
          **token_attributes
        )
      end

      def create_for(application:, resource_owner:, scopes:, **token_attributes)
        token_attributes[:application_id] = application&.id
        token_attributes[:scopes] = scopes.to_s

        if Doorkeeper.config.polymorphic_resource_owner?
          token_attributes[:resource_owner] = resource_owner
        else
          token_attributes[:resource_owner_id] = resource_owner_id_for(resource_owner)
        end

        with_primary_role do
          create!(token_attributes)
        end
      end

      def last_authorized_token_for(application_id, resource_owner_id)
        authorized_tokens_for(application_id, resource_owner_id).first
      end

      def secret_strategy
        ::Doorkeeper.configuration.token_secret_strategy
      end

      def fallback_secret_strategy
        ::Doorkeeper.configuration.token_secret_fallback_strategy
      end

      def polymorphic_resource_owner?
        columns.include?(:resource_owner_type)
      end

      # Extracts the custom attributes (configured with the
      # `custom_access_token_attributes` option) from the given attributes.
      def extract_custom_attributes(attributes)
        attributes.stringify_keys.slice(
          *Doorkeeper.configuration.custom_access_token_attributes.map(&:to_s)
        ).symbolize_keys
      end
    end

    def token_type
      "Bearer"
    end

    def use_refresh_token?
      @use_refresh_token ||= false
      !!@use_refresh_token
    end

    def as_json(_options = {})
      {
        resource_owner_id: resource_owner_id,
        scope: scopes,
        expires_in: expires_in_seconds,
        application: { uid: application.try(:uid) },
        created_at: created_at.to_i,
      }.tap do |json|
        if Doorkeeper.configuration.polymorphic_resource_owner?
          json[:resource_owner_type] = resource_owner_type
        end
      end
    end
	
    # The token's custom attributes, as defined by the
    # custom_access_token_attributes config option. Keys are symbols to match
    # the configured attribute names.
    def custom_attributes
      self.class.extract_custom_attributes(attributes.symbolize_keys)
    end

    # It indicates whether the tokens have the same credential
    def same_credential?(access_token)
      application_id == access_token.application_id &&
        same_resource_owner?(access_token)
    end

    def same_resource_owner?(access_token)
      if Doorkeeper.configuration.polymorphic_resource_owner?
        resource_owner == access_token.resource_owner
      else
        resource_owner_id == access_token.resource_owner_id
      end
    end

    def acceptable?(scopes)
      accessible? && includes_scope?(*scopes)
    end

    def plaintext_refresh_token
      if secret_strategy.allows_restoring_secrets?
        secret_strategy.restore_secret(self, :refresh_token)
      else
        @raw_refresh_token
      end
    end

    def plaintext_token
      if secret_strategy.allows_restoring_secrets?
        secret_strategy.restore_secret(self, :token)
      else
        @raw_token
      end
    end
	
    # Revokes token with `:refresh_token` equal to `:previous_refresh_token`
    # and clears `:previous_refresh_token` attribute.
    #
    def revoke_previous_refresh_token!
      return if !self.class.refresh_token_revoked_on_use? || previous_refresh_token.blank?

      old_refresh_token&.revoke
      update(previous_refresh_token: "")
    end

    private

    def old_refresh_token
      @old_refresh_token ||= self.class.by_previous_refresh_token(previous_refresh_token)
    end
	
    def generate_refresh_token
      @raw_refresh_token = UniqueToken.generate
      secret_strategy.store_secret(self, :refresh_token, @raw_refresh_token)
    end

    def generate_token
      self[:created_at] ||= Time.now.utc

      @raw_token = token_generator.generate(attributes_for_token_generator)
      secret_strategy.store_secret(self, :token, @raw_token)
      @raw_token
    end

    # Set of attributes passed to the token generator. Includes any
    # configured custom access token attributes.
    def attributes_for_token_generator
      {
        resource_owner_id: resource_owner_id,
        scopes: scopes,
        application: application,
        expires_in: expires_in,
        created_at: created_at,
      }.tap do |attrs|
        if Doorkeeper.config.polymorphic_resource_owner?
          attrs[:resource_owner] = resource_owner
        end

        Doorkeeper.config.custom_access_token_attributes.each do |attribute_name|
          attrs[attribute_name] = public_send(attribute_name)
        end
      end
    end

    def token_generator
      generator_name = Doorkeeper.configuration.access_token_generator
      generator = generator_name.constantize

      return generator if generator.respond_to?(:generate)

      raise Doorkeeper::Errors::UnableToGenerateToken, "#{generator} does not respond to `.generate`."
    rescue NameError
      raise Doorkeeper::Errors::TokenGeneratorNotFound, "#{generator_name} not found"
    end
  end
end
