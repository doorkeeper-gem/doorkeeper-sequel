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
gem "doorkeeper", ">= 5.6.6", "< 5.10"
gem "rails", "~> 7.0"
# Doorkeeper's dummy app sets config.assets.*; Rails 7+ no longer bundles
# sprockets, so the integration suite needs it explicitly.
gem "sprockets-rails"

group :test do
  gem "rspec-rails", "~> 6.0"
end

gem "rubocop", "~> 1.0", require: false
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
