module DbCharmer
  module ActiveRecord
    module Associations
      module Preloader
        module ThroughAssociation
          extend ActiveSupport::Concern

          def associated_records_by_owner(preloader)
            if model.db_charmer_top_level_connection? || reflection.options[:polymorphic] ||
                model.db_charmer_default_connection != klass.db_charmer_default_connection
              super
            else
              through_reflection.klass.on_db(model) do
                super
              end
            end
          end
        end
      end
    end
  end
end
