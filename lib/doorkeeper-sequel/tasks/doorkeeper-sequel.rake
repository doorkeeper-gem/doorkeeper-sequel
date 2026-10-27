# frozen_string_literal: true

namespace :doorkeeper_sequel do
  namespace :generate do
    desc "Generate main migration file"
    task :migration do
      DoorkeeperSequel::MigrationGenerator.start
    end

    desc "Generate migration file for Application Owner functionality"
    task :application_owner do
      DoorkeeperSequel::ApplicationOwnerGenerator.start
    end

    desc "Generate migration file for Previous Refresh Token functionality"
    task :previous_refresh_token do
      DoorkeeperSequel::PreviousRefreshTokenGenerator.start
    end

    desc "Generate migration file for PKCE"
    task :pkce do
      DoorkeeperSequel::PkceGenerator.start
    end

    desc "Add confidential column to Doorkeeper applications"
    task :confidential_applications do
      DoorkeeperSequel::ConfidentialApplicationsGenerator.start
    end

    desc "Remove NOT NULL constraint from Doorkeeper applications secret column"
    task :remove_applications_secret_not_null_constraint do
      DoorkeeperSequel::RemoveApplicationsSecretNotNullConstraintGenerator.start
    end

    desc "Add resource owner type to Access tokens and grants"
    task :polymorphic_resource_owner do
      DoorkeeperSequel::PolymorphicResourceOwnerGenerator.start
    end

    desc "Add resource indicators (RFC 8707) support to Access tokens and grants"
    task :resource_indicators do
      DoorkeeperSequel::ResourceIndicatorsGenerator.start
    end

    desc "Add refresh_token_scopes column to Access tokens"
    task :refresh_token_scopes do
      DoorkeeperSequel::RefreshTokenScopesGenerator.start
    end

    desc "Add access_token_id reference to Access grants (grant reuse revocation)"
    task :grant_reuse_revocation do
      DoorkeeperSequel::GrantReuseRevocationGenerator.start
    end
  end
end
