# Doorkeeper Sequel ORM extension
[![Gem Version](https://badge.fury.io/rb/doorkeeper-sequel.svg)](https://rubygems.org/gems/doorkeeper-sequel)
[![Build Status](https://github.com/doorkeeper-gem/doorkeeper-sequel/actions/workflows/ci.yml/badge.svg)](https://github.com/doorkeeper-gem/doorkeeper-sequel/actions/workflows/ci.yml)
[![Code Climate](https://codeclimate.com/github/doorkeeper-gem/doorkeeper-sequel/badges/gpa.svg)](https://codeclimate.com/github/doorkeeper-gem/doorkeeper-sequel)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](#license)

`doorkeeper-sequel` provides [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) support to [Sequel](https://github.com/jeremyevans/sequel) database toolkit.

## Requirements

* Doorkeeper >= 5.6.6
* Rails >= 7.0
* Ruby >= 2.7
* Sequel >= 4

## Installation

To start using the Doorkeeper Sequel ORM, add to your Gemfile:

``` ruby
# For Doorkeeper 4.x
gem 'doorkeeper', '~> 4.3'
gem 'doorkeeper-sequel', '~> 1.5'

# For Doorkeeper 5.1
gem 'doorkeeper', '~> 5.0' # or 5.1
gem 'doorkeeper-sequel', '~> 2.0'

# For Doorkeeper >= 5.2
gem 'doorkeeper', '~> 5.2'
gem 'doorkeeper-sequel', '~> 2.1'

# For Doorkeeper >= 5.3
gem 'doorkeeper', '~> 5.3'
gem 'doorkeeper-sequel', '~> 2.2'

# For Doorkeeper >= 5.6.6
gem 'doorkeeper', '~> 5.9'
gem 'doorkeeper-sequel', '~> 2.5'
```

Or you can use git `master` branch for the latest gem version:
  
``` ruby
gem 'doorkeeper-sequel', git: 'https://github.com/doorkeeper-gem/doorkeeper-sequel.git'
```

Set the Doorkeeper ORM configuration:

``` ruby
Doorkeeper.configure do
  orm :sequel
end
```

Generate migrations:

```
rake doorkeeper_sequel:generate:migration
rake doorkeeper_sequel:generate:application_owner
rake doorkeeper_sequel:generate:previous_refresh_token
rake doorkeeper_sequel:generate:confidential_applications
rake doorkeeper_sequel:generate:pkce # for Doorkeeper >= 5.x
rake doorkeeper_sequel:generate:polymorphic_resource_owner # for Doorkeeper >= 5.3
rake doorkeeper_sequel:generate:remove_applications_secret_not_null_constraint # for Doorkeeper >= 5.8 (public clients)
```

## Tests

To run tests, clone this repository and run `rake`. It will copy and run `Doorkeeper`’s original test suite after configuring the ORM and other stuffs.

```
$ bundle exec rake
```

## Contributing

You are very welcome to help improve `doorkeeper-sequel` if you have suggestions for features that other people can use or some code improvements.

To contribute:

1. Fork the project.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Add tests for your feature or bug fix.
6. Run `rake` to make sure all tests pass.
7. Commit your changes (`git commit -am 'Add new feature'`).
8. Push to the branch (`git push origin my-new-feature`).
9. Create new pull request.

Thanks.

## License

Doorkeeper-sequel gem is released under the [MIT License](http://www.opensource.org/licenses/MIT).

Copyright (c) 2016-2026 Nikita Bulai (bulajnikita@gmail.com).

---

Please refer to [https://github.com/doorkeeper-gem/doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) for instructions on
doorkeeper’s project.
