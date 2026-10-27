# Doorkeeper-Sequel ORM Changelog

Reverse Chronological Order:

## master

https://github.com/doorkeeper-gem/doorkeeper-sequel/compare/2.5.0...master

* Allow Doorkeeper 6.0 (including `6.0.0.rc`): relax the dependency to
  `>= 5.6.6` and `< 6.1`. The extension supports both the 5.x and 6.0 lines,
  with the 6.0-only features activating only when their columns / config /
  library methods are present.
* Add support for Resource Indicators (RFC 8707): the `resource` column is
  honored on access grants and tokens, token reuse is audience-restricted
  (`resource_indicators_match?`), and a `doorkeeper_sequel:generate:resource_indicators`
  migration generator is provided.
* Add support for the `refresh_token_scopes` column (RFC 6749 §6): a refresh
  token keeps the originally granted scope across narrowing refreshes, with a
  `doorkeeper_sequel:generate:refresh_token_scopes` generator.
* Add support for authorization-code reuse revocation via the grant
  `access_token_id` column, with a `doorkeeper_sequel:generate:grant_reuse_revocation`
  generator.
* Honor `private_key_jwt` client authentication (RFC 7523): the optional
  `jwks` / `jwks_uri` application attributes are mass-assignable.
* Upgrade a plain application secret to the active strategy on a successful
  fallback match (Sequel conditional write), matching Doorkeeper 6.0.
* Add ActiveRecord-compatible helpers used by Doorkeeper 6.0
  (`where.not`, `exists?(id)`, `update_columns`, `destroy!`, identity-based
  `==`/`eql?`/`hash`).
* Forward-compatible ORM wiring: define `run_hooks` (silencing the
  `setup_orm_models` deprecation) and gate the application owner association
  on `enable_application_owner?`.

## `2.5.0`

* Support for Doorkeeper up to 5.9.x
* Add support for custom access token attributes (`custom_access_token_attributes`)
* Support nullable application secrets for public clients (Doorkeeper >= 5.8)
* Honor the `application_secret_generator` configuration option
* Reject redirect URIs with a script scheme (`javascript`, `vbscript`, `data`)
  and require a host, matching the Doorkeeper 5.9.9 security fixes
* Exclude endless (`expires_in IS NULL`) tokens from `StaleRecordsCleaner` and
  use per-adapter expiration-time math when cleaning/matching tokens
* Store and read timestamps as UTC (`Sequel.default_timezone = :utc`) so token
  expiration math is correct regardless of the host system timezone
* Add `active_for`, `not_expired`, `same_resource_owner?` and a no-op
  `with_primary_role` to keep parity with the ActiveRecord ORM mixins

## `2.4.0` (2021-03-11)

* Support for Doorkeeper 5.5

## `2.0.0` (2018-10-04)

https://github.com/nbulaj/doorkeeper-sequel/compare/1.5.0...2.0.0

* Support Doorkeeper >= 5.0.0

## `1.5.0` (2018-10-03)

https://github.com/nbulaj/doorkeeper-sequel/compare/1.4.0...1.5.0

* Support Doorkeeper >= 4.2.7 && < 5.0.0

## `1.4.0` (2018-02-08)

https://github.com/nbulaj/doorkeeper-sequel/compare/1.3.1...1.4.0

* Various fixes
* Update Doorkeeper to upstream

## `1.3.1` (2017-12-14)

https://github.com/nbulaj/doorkeeper-sequel/compare/1.3.0...1.3.1

* Fix Sequel model initialization (database error for rake tasks)
* Fix main migration name for generator

## `1.3.0` (2017-12-13)

https://github.com/nbulaj/doorkeeper-sequel/compare/1.2.3...1.3.0

* Fix dependencies to allow using of Sequel 5
* Fix models plugins for Sequel >= 4.47
* Fix generators to allow migration generation when tables not created

## `1.2.3` (2017-08-10)

https://github.com/nbulaj/doorkeeper-sequel/compare/1.2.2...1.2.3

* Test against stable Rails 5.1
* Update Doorkeeper submodule

## `1.2.2` (2017-06-07)

https://github.com/nbulaj/doorkeeper-sequel/compare/1.2.1...1.2.2

* ORM code refactoring
* Fix Sequel deprecations (>= 4.47)
* Update Doorkeeper submodule (support up to 4.2.6)
* Fix `#table_exists?` method for models
* `Rakefile` refactoring
* Remove Gemfile.lock

## `1.2.1` (2016-10-12)

https://github.com/nbulaj/doorkeeper-sequel/compare/1.2.0...1.2.1

* Association dependencies changed to `:delete` instead of `:destroy` (in accordance to Doorkeeper)
* Fixed generators and specs for it
* Code refactoring with [rubocop](https://github.com/bbatsov/rubocop)
* No braking changes

## `1.2.0` (2016-09-05)

https://github.com/nbulaj/doorkeeper-sequel/compare/1.0.0...1.2.0

* Added compatibility with Doorkeeper 4.2
* No braking changes

## `1.0.0` (2016-05-17)

* First stable release
* Compatible with Doorkeeper >= 4.x and Rails >= 4.x
