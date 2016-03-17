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
            rel.db_charmer_connection = @other.db_charmer_connection if rel.db_charmer_connection.nil?
            rel.db_charmer_enable_slaves = @other.db_charmer_enable_slaves if rel.db_charmer_enable_slaves.nil?
            rel.db_charmer_connection_is_forced = @other.db_charmer_connection_is_forced if rel.db_charmer_connection_is_forced.nil?
          end
        end
      end
    end
  end
end

