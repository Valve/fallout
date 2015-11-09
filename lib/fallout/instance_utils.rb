module Fallout
  module InstanceUtils
    def verify_instance_or_raise(instance)
      if instance.nil? || !instance.exists?
        raise "Instance does not exist: #{@instance_id}"
      else
        instance
      end
    end
  end
end
