# frozen_string_literal: true

module DoorkeeperSequel
  # Generates a migration adding the `resource` column to access grants and
  # access tokens, required for RFC 8707 Resource Indicators support
  # (Doorkeeper >= 6.0). Counterpart to Doorkeeper's
  # `ResourceIndicatorsGenerator`.
  class ResourceIndicatorsGenerator < ::Thor::Group
    include ::Thor::Actions
    include MigrationActions

    source_root File.expand_path("templates", __dir__)

    desc "Add resource indicators support (RFC 8707) to Doorkeeper tables."

    def install
      create_migration "enable_resource_indicators_migration"
    end
  end
end
