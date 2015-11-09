module Fallout
  module VolumeUtils
    def verify_volume_or_raise(volume)
      unless %w(in-use available).include?(volume.state)
        raise "Volume #{volume.id} does not exist or not in a valid state. Valid states are 'in-use' or 'available'"
      else
        volume
      end
    end
  end
end
