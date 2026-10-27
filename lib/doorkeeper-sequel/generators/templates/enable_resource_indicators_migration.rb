# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:oauth_access_grants) do
      add_column :resource, String, text: true, null: true
    end
    alter_table(:oauth_access_tokens) do
      add_column :resource, String, text: true, null: true
    end
  end
end
