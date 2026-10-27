# frozen_string_literal: true

module DoorkeeperSequel
  # Generates a migration that drops the NOT NULL constraint on the
  # `oauth_applications.secret` column, allowing public clients to be stored
  # with a blank secret (Doorkeeper >= 5.8). Counterpart to Doorkeeper's
  # `RemoveApplicationsSecretNotNullConstraintGenerator`.
  class RemoveApplicationsSecretNotNullConstraintGenerator < ::Thor::Group
    include ::Thor::Actions
    include MigrationActions

    source_root File.expand_path("templates", __dir__)

    desc "Removes NOT NULL constraint for OAuth2 applications secret column."

    def install
      create_migration "remove_applications_secret_not_null_constraint"
    end
  end
end
