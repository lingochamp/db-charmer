module DbCharmer
  module ActiveRecord
    module Relation
      module Merger
        extend ActiveSupport::Concern

        included do
          alias_method_chain :merge, :db_charmer
        end

        def merge_with_db_charmer
          merge_without_db_charmer.tap do |rel|
            rel.db_charmer_connection = @other.db_charmer_connection
            rel.db_charmer_enable_slaves = @other.db_charmer_enable_slaves
            rel.db_charmer_connection_is_forced = @other.db_charmer_connection_is_forced
          end
        end
      end
    end
  end
end

