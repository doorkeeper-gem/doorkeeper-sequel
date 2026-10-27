# SQLite memory database
DB = if defined?(JRUBY_VERSION)
       Sequel.connect('jdbc:sqlite::memory:')
     else
       Sequel.sqlite
     end

DB.create_table :oauth_applications do
  primary_key :id

  column :name, String, size: 255, null: false
  column :uid, String, size: 255, null: false, index: { unique: true }
  column :secret, String, size: 255, null: false

  column :scopes, String, size: 255, null: false, default: ''
  column :redirect_uri, String
  column :confidential, TrueClass, null: false, default: true

  column :created_at, DateTime
  column :updated_at, DateTime

  column :owner_id, Integer
  column :owner_type, String
  index [:owner_id, :owner_type]
end

DB.create_table :oauth_access_grants do
  primary_key :id
  column :application_id, Integer

  column :resource_owner_id, Integer, null: false, index: true
  column :resource_owner_type, String, index: true

  column :token, String, size: 255, null: false, index: { unique: true }
  column :expires_in, Integer, null: false
  column :redirect_uri, String, null: false
  column :created_at, DateTime, null: false
  column :revoked_at, DateTime
  column :scopes, String, size: 255

  column :code_challenge, String
  column :code_challenge_method, String

  # Custom attribute used by Doorkeeper's custom_access_token_attributes specs.
  column :tenant_name, String
end

DB.create_table :oauth_access_tokens do
  primary_key :id
  column :application_id, Integer

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
  column :previous_refresh_token, String, size: 255, null: false, default: ''
  column :expires_in, Integer
  column :revoked_at, DateTime
  column :created_at, DateTime, null: false
  column :scopes, String, size: 255

  # Custom attribute used by Doorkeeper's custom_access_token_attributes specs.
  column :tenant_name, String
end

DB.create_table :users do
  primary_key :id
  column :name, String, size: 255
  column :created_at, DateTime
  column :updated_at, DateTime
  column :password, String, size: 255
end
