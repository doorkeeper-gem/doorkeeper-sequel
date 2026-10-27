# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:oauth_access_grants) do
      # Indexed: when a code is replayed, the revocation checks whether the
      # issued token is still referenced by another grant, which filters
      # oauth_access_grants by access_token_id.
      add_column :access_token_id, Integer, index: true, null: true
    end
  end
end
