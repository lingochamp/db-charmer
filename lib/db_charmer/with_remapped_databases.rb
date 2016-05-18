require 'db_charmer/active_record/hijack_child_classes'

module DbCharmer
  def self.with_remapped_databases(mappings, &proc)
    old_mappings = ::ActiveRecord::Base.db_charmer_database_remappings
    begin
      ::ActiveRecord::Base.db_charmer_database_remappings = mappings
      if mappings[:master] || mappings['master']
        with_all_hijacked(&proc)
      else
        proc.call
      end
    ensure
      ::ActiveRecord::Base.db_charmer_database_remappings = old_mappings
    end
  end

  def self.hijack_new_classes?
    !! Thread.current[:db_charmer_hijack_new_classes]
  end

private

  def self.with_all_hijacked
    old_hijack_new_classes = Thread.current[:db_charmer_hijack_new_classes]
    begin
      Thread.current[:db_charmer_hijack_new_classes] = true
      ::ActiveRecord::Base.descendants.each do |subclass|
        subclass.hijack_connection!
      end
      yield
    ensure
      Thread.current[:db_charmer_hijack_new_classes] = old_hijack_new_classes
    end
  end
end

#---------------------------------------------------------------------------------------------------
# Hijack connection on all new AR classes when we're in a block with main AR connection remapped
::ActiveRecord::Base.send(:extend, DbCharmer::ActiveRecord::HijackChildClasses)

