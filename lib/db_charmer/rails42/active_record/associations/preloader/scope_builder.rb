module DbCharmer
  module ActiveRecord
    module Associations
      module Preloader
        module ScopeBuilder
          extend ActiveSupport::Concern

          def build_scope
            # puts("(#{klass.name}) build_scope:")
            # puts("(#{klass.name}) model = #{model.name}")
            # puts("(#{klass.name}) model.db_charmer_connection_level = #{model.db_charmer_connection_level.inspect}")
            # puts("(#{klass.name}) model.db_charmer_top_level_connection? = #{model.db_charmer_top_level_connection?.inspect}")
            # puts("(#{klass.name}) reflection.options[:polymorphic] = #{reflection.options[:polymorphic].inspect}")
            # puts("(#{klass.name}) model.db_charmer_default_connection != klass.db_charmer_default_connection = #{model.db_charmer_default_connection != klass.db_charmer_default_connection}")

            if model.db_charmer_top_level_connection? || reflection.options[:polymorphic] ||
                model.db_charmer_default_connection != klass.db_charmer_default_connection
              super
            else
              super.on_db(model)
            end
          end

          # def reflection_scope
          #   @reflection_scope ||= lambda do
          #     puts("(#{klass.name}) reflection_scope:")
          #     puts("(#{klass.name}) model = #{model.name}")
          #     puts("(#{klass.name}) model.db_charmer_connection_level = #{model.db_charmer_connection_level.inspect}")
          #     puts("(#{klass.name}) model.db_charmer_top_level_connection? = #{model.db_charmer_top_level_connection?.inspect}")
          #     puts("(#{klass.name}) reflection.options[:polymorphic] = #{reflection.options[:polymorphic].inspect}")
          #     puts("(#{klass.name}) model.db_charmer_default_connection != klass.db_charmer_default_connection = #{model.db_charmer_default_connection != klass.db_charmer_default_connection}")

          #     if model.db_charmer_top_level_connection? || reflection.options[:polymorphic] ||
          #         model.db_charmer_default_connection != klass.db_charmer_default_connection
          #       super
          #     else
          #       super.on_db(model)
          #     end
          #   end.call
          # end
          
        end
      end
    end
  end
end
