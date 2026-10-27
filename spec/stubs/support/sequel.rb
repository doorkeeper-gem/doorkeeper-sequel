# frozen_string_literal: true

# TODO: review these
# Some examples in Doorkeeper's shared suite are written directly against
# ActiveRecord internals and cannot run under the Sequel ORM:
#
#   * "read replica support" / WriteToPrimary — assert on
#     `ActiveRecord::Base.connected_to(role: :writing)`. Sequel routes every
#     write to the primary (`:default`) server automatically, so there is no
#     equivalent call to assert (see DoorkeeperSequel::SequelCompat#with_primary_role).
#   * The `build_application_model` helper builds `ActiveRecord::Base`
#     subclasses and uses `reflect_on_association`, which don't exist on
#     Sequel models.
#
# We tag those examples as ActiveRecord-only (by file/description) and exclude
# them, rather than patching the vendored specs.
AR_ONLY_DESCRIPTION_PATTERNS = [
  /read replica support/,
  /application_owner is enabled/,
  /as_json when called with authorized resource owner/,
  /does not declare the/,
].freeze

RSpec.configure do |config|
  # Tag matching example groups/examples so they can be filtered out.
  config.define_derived_metadata(file_path: %r{/write_to_primary_spec\.rb}) do |meta|
    meta[:active_record_only] = true
  end

  config.define_derived_metadata do |meta|
    description = meta[:full_description].to_s
    if AR_ONLY_DESCRIPTION_PATTERNS.any? { |re| description.match?(re) }
      meta[:active_record_only] = true
    end
  end

  config.filter_run_excluding(active_record_only: true)
end
