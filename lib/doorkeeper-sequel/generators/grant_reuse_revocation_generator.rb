# frozen_string_literal: true

module DoorkeeperSequel
  # Generates a migration adding the `access_token_id` reference to access
  # grants, enabling authorization-code replay revocation
  # (RFC 6749 §4.1.2, §10.5, Doorkeeper >= 6.0). Counterpart to Doorkeeper's
  # `GrantReuseRevocationGenerator`.
  class GrantReuseRevocationGenerator < ::Thor::Group
    include ::Thor::Actions
    include MigrationActions

    source_root File.expand_path("templates", __dir__)

    desc "Add access_token_id reference to Doorkeeper access grants."

    def install
      create_migration "add_access_token_to_access_grants"
    end
  end
end
