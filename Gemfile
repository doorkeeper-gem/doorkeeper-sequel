# frozen_string_literal: true

source "https://rubygems.org"

gemspec

platforms :jruby do
  gem "jdbc-sqlite3"
end

platforms :ruby, :mswin, :mswin64, :mingw, :x64_mingw do
  gem "sqlite3", "~> 1.6.0"
end

gem "sequel", ">= 4.0"
gem "sequel_polymorphic"

gem "bcrypt", "~> 3.1"
gem "doorkeeper", "6.0.0.rc2"
gem "rails", "~> 7.0"
# Doorkeeper's dummy app sets config.assets.*; Rails 7+ no longer bundles
# sprockets, so the integration suite needs it explicitly.
gem "sprockets-rails"

# Doorkeeper >= 6.0 private_key_jwt client authentication (RFC 7523) specs.
gem "jwt", ">= 2.7"
# Doorkeeper's private_key_jwt / http_fetcher specs stub HTTP with WebMock.
gem "webmock"

group :test do
  gem "rspec-rails", "~> 6.0"
end

gem "rubocop", "~> 1.0", require: false
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
