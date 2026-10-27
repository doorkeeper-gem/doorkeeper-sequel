# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:oauth_applications) do
      set_column_allow_null :secret
    end
  end
end
