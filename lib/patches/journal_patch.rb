module Patches
  module JournalPatch

    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      end
    end

    module InstanceMethods
      def notified_users
        notified = journalized.notified_users
        notified = notified.select {|u| u.active? && u.notify_about?(self)}
        notified += Setting.plugin_event_notifications["enable_event_notifications"] == "on" ? journalized.project.notified_users(self) :
             journalized.project.notified_users

        notified.uniq!

        if private_notes?
          notified = notified.select {|user| user.allowed_to?(:view_private_notes, journalized.project)}
        end
        notified
      end
    end
  end
end

Journal.send(:include, Patches::JournalPatch)