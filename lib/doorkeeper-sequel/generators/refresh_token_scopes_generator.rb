# frozen_string_literal: true

module DoorkeeperSequel
  # Generates a migration adding the `refresh_token_scopes` column to access
  # tokens, so a refresh token keeps the scope originally granted
  # (RFC 6749 §6, Doorkeeper >= 6.0). Counterpart to Doorkeeper's
  # `RefreshTokenScopesGenerator`.
  class RefreshTokenScopesGenerator < ::Thor::Group
    include ::Thor::Actions
    include MigrationActions

    source_root File.expand_path("templates", __dir__)

    desc "Add refresh_token_scopes column to Doorkeeper access tokens."

    def install
      create_migration "add_refresh_token_scopes_to_access_tokens"
    end
  end
end
