# frozen_string_literal: true

# Sequel's `many_to_one` association setter copies the associated record's
# primary key into the foreign key on assignment, so the associated object
# must already be persisted. Doorkeeper's upstream factories `build` (do not
# save) the application, which works under ActiveRecord but raises
# "does not have a primary key" under Sequel. We therefore force the
# `application` association to be created (persisted) before assignment.
FactoryBot.define do
  factory :access_grant, class: "Doorkeeper::AccessGrant" do
    sequence(:resource_owner_id) { |n| n }
    association :application, strategy: :create
    redirect_uri { "https://app.com/callback" }
    expires_in { 100 }
    scopes { "public write" }
  end

  factory :access_token, class: "Doorkeeper::AccessToken" do
    sequence(:resource_owner_id) { |n| n }
    association :application, strategy: :create
    expires_in { 2.hours }

    factory :clientless_access_token do
      application { nil }
    end
  end

  factory :application, class: "Doorkeeper::Application" do
    sequence(:name) { |n| "Application #{n}" }
    redirect_uri { "https://app.com/callback" }
  end

  # do not name this factory :user, otherwise it will conflict with factories
  # from applications that use doorkeeper factories in their own tests
  factory :doorkeeper_testing_user, class: :user, aliases: [:resource_owner]
end
