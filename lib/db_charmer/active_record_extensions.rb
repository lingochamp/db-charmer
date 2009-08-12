module DbCharmer
  module ActiveRecordExtensions
    module ClassMethods
      def establish_real_connection_if_exists(name, should_exist = false)
        config = configurations[RAILS_ENV][name.to_s]
        if should_exist && !config
          raise ArgumentError, "Invalid connection name (does not exist in database.yml): #{RAILS_ENV}/#{name}"
        end
        establish_connection(config) if config
      end
      
      @@db_charmer_connection_proxies = {}
      def db_charmer_connection_proxy=(proxy)
        @@db_charmer_connection_proxies[self.to_s] = proxy
      end

      def db_charmer_connection_proxy
        @@db_charmer_connection_proxies[self.to_s]
      end
      
      def hijack_connection!
        class_eval <<-EOF
          def self.connection
            db_charmer_connection_proxy || super
          end
        EOF
      end
    end
  end
end