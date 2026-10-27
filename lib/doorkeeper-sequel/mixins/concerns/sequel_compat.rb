# frozen_string_literal: true

module DoorkeeperSequel
  module SequelCompat
    extend ActiveSupport::Concern

    # ActiveRecord methods used by Doorkeeper outside the ORM.
    # Should be extracted at the architectural level.
    included do
      plugin :active_model

      # Sequel 4.47 and higher deprecated #set_allowed_columns
      plugin :whitelist_security if (::Sequel::MAJOR >= 4 && ::Sequel::MINOR >= 47) || ::Sequel::MAJOR >= 5

      self.raise_on_save_failure = false

      # ActiveRecord relations respond to #size; Doorkeeper (and its specs)
      # rely on it. Expose it on this model's datasets as an alias of #count.
      dataset_module do
        def size
          count
        end
      end

      def update_attribute(column, value)
        self[column] = value
        save(columns: [column.to_sym], validate: false)
      end

      alias_method :update_column, :update_attribute

      def update_attributes(*args)
        update(*args)
      end

      # ActiveModel-style bang update used by Doorkeeper core and its specs.
      # Assigns directly (bypassing the whitelist_security mass-assignment
      # protection) so any column — including timestamps like created_at —
      # can be updated, matching ActiveRecord's #update!.
      def update!(values)
        values.each { |column, value| self[column.to_sym] = value }
        save(raise_on_failure: true)
      end

      # Mimics ActiveRecord's #attributes: a stringified-key hash of the
      # record's values. Needed by Doorkeeper's custom access token
      # attributes support (#extract_custom_attributes).
      def attributes
        values.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v }
      end

      # Permit configured custom access token attributes (Doorkeeper >= 5.6)
      # on mass-assignment. They are configurable at runtime, so they can't be
      # baked into the static `set_allowed_columns` lists of the AccessToken /
      # AccessGrant mixins. We pull any configured + existing custom column out
      # of the hash and assign it directly (bypassing whitelist_security),
      # letting the normal whitelisted path handle the remaining attributes.
      #
      # This matters on the real write path (e.g. AccessGrant.create! during
      # the authorization code flow, which merges custom attributes into the
      # grant so they can be copied onto the issued access token).
      def set(hash)
        custom = Doorkeeper.config.custom_access_token_attributes
        unless custom.empty?
          hash = hash.dup
          custom.each do |attr|
            next unless self.class.columns.include?(attr.to_sym)

            if hash.key?(attr)
              self[attr.to_sym] = hash.delete(attr)
            elsif hash.key?(attr.to_s)
              self[attr.to_sym] = hash.delete(attr.to_s)
            end
          end
        end
        super(hash)
      end

      def save!(*)
        save(raise_on_failure: true)
      end

      def transaction(opts = {}, &block)
        db.transaction(opts, &block)
      end

      def invalid?
        !valid?
      end

      def exists?
        !empty?
      end
	  
      def with_lock
        return yield if @_tr_is_locked
        @_tr_is_locked = true
      
        begin
          db.transaction do
            lock!
            yield
          end
        ensure
          @_tr_is_locked = false
        end
      end

      alias_method :exist?, :exists?
    end

    module ClassMethods
      def create!(values = {}, &block)
        new(values, &block).save(raise_on_failure: true)
      end

      # Executes the given block against the primary (writable) database.
      #
      # This is the Sequel counterpart to Doorkeeper's ActiveRecord
      # read-replica support (`enable_multiple_database_roles`, which wraps
      # writes in `connected_to(role: :writing)` because AR may route a GET
      # request to a read replica).
      #
      # Sequel models the read/write split with *servers/shards* on a single
      # `Sequel::Database`: writes (INSERT/UPDATE/DELETE) are always sent to
      # the `:default` (primary) server, and only reads are routed to a
      # replica when a dataset explicitly opts in with `.server(:replica)`.
      # Because Sequel never sends a write to a replica implicitly, there is
      # no role to switch for the write path — we just run the block.
      #
      # @see https://sequel.jeremyevans.net/rdoc/files/doc/sharding_rdoc.html
      def with_primary_role
        yield
      end

      def table_exists?
        db.table_exists?(table_name)
      end

      def ordered_by(attribute, direction = :asc)
        order(::Sequel.public_send(direction, attribute))
      end

      # find(1) or find("1") - will work like find(id: 1)
      # find(name: 'John') - will work like find(name: 'John')
      def find(*args, &block)
        if args.first.is_a?(Hash)
          super(*args, &block)
        else
          super(id: args)
        end
      end

      def exists?(*args)
        if args.any?
          !where(*args).empty?
        else
          !empty?
        end
      end

      # SQL expression computing the number of seconds elapsed since the
      # record's created_at up to +now+. Used to evaluate token expiration
      # (created_at + expires_in <=> now) in a single query across adapters,
      # mirroring Doorkeeper's ActiveRecord ExpirationTimeSqlMath.
      EXPIRATION_TIME_ADAPTERS = %w[sqlite postgres postgresql mysql mysql2 mssql sqlserver].freeze

      # Name of the underlying database adapter, e.g. "sqlite", "postgres".
      def adapter_name
        db.database_type.to_s
      end

      def supports_expiration_time_math?
        EXPIRATION_TIME_ADAPTERS.include?(adapter_name.downcase)
      end

      def seconds_since_created_sql(now = Time.now.utc)
        case adapter_name.downcase
        when "sqlite"
          ::Sequel.lit("(julianday(?) - julianday(created_at)) * 86400", now)
        when "postgres", "postgresql"
          ::Sequel.lit("EXTRACT(EPOCH FROM (CAST(? AS timestamp) - created_at))", now)
        when "mysql", "mysql2"
          ::Sequel.lit("TIMESTAMPDIFF(SECOND, created_at, ?)", now)
        when "mssql", "sqlserver"
          ::Sequel.lit("DATEDIFF(SECOND, created_at, ?)", now)
        else
          ::Sequel.lit("EXTRACT(EPOCH FROM (CAST(? AS timestamp) - created_at))", now)
        end
      end

      # Condition matching non-expired tokens/grants: either no expiry set
      # (endless) or the elapsed time is still below expires_in.
      def not_expired_condition(now = Time.now.utc)
        ::Sequel.|({ expires_in: nil }, (seconds_since_created_sql(now) < :expires_in))
      end
    end
  end
end
