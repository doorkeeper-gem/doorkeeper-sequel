# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:oauth_access_tokens) do
      # Existing rows are left NULL: their refresh tokens keep behaving as
      # before (validated against the access token's own scope) until they
      # are rotated, at which point the new row records the granted scope.
      add_column :refresh_token_scopes, String
    end
  end
end
