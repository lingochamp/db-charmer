module DbCharmer
  module ActiveRecord
    module HijackChildClasses
      def inherited(subclass)
        hijack_connection! if DbCharmer.hijack_new_classes?
        super
      end
    end
  end
end

