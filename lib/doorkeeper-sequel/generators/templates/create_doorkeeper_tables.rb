# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :oauth_applications do
      primary_key :id

      column :name, String, size: 255, null: false
      column :uid, String, size: 255, null: false, index: { unique: true }
      # Remove `null: false` if you are planning to use public clients
      # (Doorkeeper >= 5.8 allows applications with a blank secret).
      column :secret, String, size: 255, null: false

      column :scopes, String, size: 255, null: false, default: ""
      column :redirect_uri, String
      column :confidential, TrueClass, null: false, default: true

      column :created_at, DateTime
      column :updated_at, DateTime
    end

    create_table :oauth_access_grants do
      primary_key :id
      foreign_key :application_id, :oauth_applications, null: false, on_delete: :cascade

      column :resource_owner_id, Integer, null: false, index: true
      column :resource_owner_type, String, null: false, index: true

      column :token, String, size: 255, null: false, index: { unique: true }
      column :expires_in, Integer, null: false
      column :redirect_uri, String, null: false
      column :created_at, DateTime, null: false
      column :revoked_at, DateTime
      column :scopes, String, size: 255

      # Authorization codes are single-use (RFC 6749 §4.1.2). Doorkeeper
      # records the access token issued when the code is exchanged so that a
      # second exchange attempt revokes the previously issued tokens
      # (RFC 6749 §10.5). Comment out to disable that revocation.
      column :access_token_id, Integer, index: true
    end

    create_table :oauth_access_tokens do
      primary_key :id
      foreign_key :application_id, :oauth_applications, null: false, on_delete: :cascade

      column :resource_owner_id, Integer, index: true
      column :resource_owner_type, String, index: true

      # If you use a custom token generator you may need to change this column
      # from string to text, so that it accepts tokens larger than 255
      # characters. More info on custom token generators in:
      # https://github.com/doorkeeper-gem/doorkeeper/tree/v3.0.0.rc1#custom-access-token-generator
      #
      # column :token, String, null: false
      column :token, String, size: 255, null: false, index: { unique: true }

      column :refresh_token, String, size: 255, index: { unique: true }
      # If there is a previous_refresh_token column,
      # refresh tokens will be revoked after a related access token is used.
      # If there is no previous_refresh_token column,
      # previous tokens are revoked as soon as a new access token is created.
      # Comment out this line if you'd rather have refresh tokens
      # instantly revoked.
      column :previous_refresh_token, String, size: 255, null: false, default: ""
      column :expires_in, Integer
      column :revoked_at, DateTime
      column :created_at, DateTime, null: false
      column :scopes, String, size: 255

      # A refresh token keeps the scope originally granted by the resource
      # owner, so a client that narrowed an access token on one refresh can
      # request the granted scope again on the next (RFC 6749 §6). Comment
      # out to let a narrowed refresh permanently narrow the refresh token.
      column :refresh_token_scopes, String, size: 255
    end
  end
end
