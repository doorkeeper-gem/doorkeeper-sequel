# frozen_string_literal: true

module DoorkeeperSequel
  module RedirectUriValidator
    extend ActiveSupport::Concern

    included do
      def validates_redirect_uri(attribute)
        value = self[attribute]

        # Allow nil? but do not allow empty string
        if value.blank?
          if Doorkeeper.configuration.allow_blank_redirect_uri?(self)
            true
          else
            add_error(attribute, :blank)
          end
        else
          value.split.each do |val|
            next if oob_redirect_uri?(val)

            uri = ::URI.parse(val)
            validate_uri(uri, attribute)
          end
        end
      rescue URI::InvalidURIError
        add_error(attribute, :invalid_uri)
      end

      private

      def oob_redirect_uri?(uri)
        ::Doorkeeper::OAuth::NonStandard::IETF_WG_OAUTH2_OOB_METHODS.include?(uri)
      end

      def native_redirect_uri?(uri)
        native_redirect_uri.present? && uri.to_s == native_redirect_uri.to_s
      end

      def forbidden_uri?(uri)
        return true if ::Doorkeeper::OAuth::Helpers::URIChecker.script_scheme?(uri)

        Doorkeeper.configuration.respond_to?(:forbid_redirect_uri) &&
          Doorkeeper.configuration.forbid_redirect_uri.call(uri)
      end

      def validate_uri(uri, attribute)
        {
          fragment_present: uri.fragment.present?,
          secured_uri: invalid_ssl_uri?(uri),
          forbidden_uri: forbidden_uri?(uri),
          unspecified_scheme: unspecified_scheme?(uri),
          unspecified_host: unspecified_host?(uri),
          relative_uri: relative_uri?(uri),
        }.each do |error, condition|
          add_error(attribute, error) if condition
        end
      end

      def unspecified_scheme?(uri)
        return true if uri.opaque.present?

        %w[localhost].include?(uri.try(:scheme))
      end
	  
	  
      def unspecified_host?(uri)
        uri.is_a?(URI::HTTP) && uri.host.blank?
      end

      def relative_uri?(uri)
        uri.scheme.nil? && uri.host.blank?
      end

      def invalid_ssl_uri?(uri)
        forces_ssl = Doorkeeper.configuration.force_ssl_in_redirect_uri
        non_https = uri.try(:scheme) == "http"

        if forces_ssl.respond_to?(:call)
          forces_ssl.call(uri) && non_https
        else
          forces_ssl && non_https
        end
      end

      def native_redirect_uri
        Doorkeeper.configuration.native_redirect_uri
      end

      def add_error(attribute, error)
        scope = "sequel.errors.models.doorkeeper/application.attributes.redirect_uri"
        errors.add(attribute, I18n.t(error, scope: scope))
      end
    end
  end
end
