module Fallout
  class Restore
    include VolumeUtils, InstanceUtils
    attr_reader :volume
    def initialize(options)
      @instance_id = options[:instance]
      @instance = verify_instance_or_raise(Aws::EC2::Instance.new(@instance_id))
      @volume_id = options[:volume]
      @volume = verify_volume_or_raise(Aws::EC2::Volume.new(@volume_id))
      @ec2 = Aws::EC2::Client.new
      if ENV['AWS_REGION']
        @availability_zone = ENV['AWS_AVAILABILITY_ZONE'] || "#{ENV['AWS_REGION']}a"
      else
        raise 'AWS_REGION is a required env variable. Please see the list of available regions at: http://goo.gl/0b2VOE'
      end
      @attach_as_device = ENV['AWS_ATTACH_VOLUME_AS_DEVICE'] || '/dev/sda1'
    end

    def stop_instance
      @instance.stop
      @instance.wait_until_stopped
      @instance
    end

    def start_instance
      @instance.start
      @instance.wait_until_running
      @instance
    end

    def detach_volume
      volume_attachment = volume.detach_from_instance(instance_id: @instance_id, device: @attach_as_device)
      @ec2.wait_until(:volume_available, volume_ids: [volume.id])
      volume_attachment
    end

    def attach_volume(volume)
      attach_options = {instance_id: @instance_id, device: @attach_as_device}
      volume.attach_to_instance(attach_options)
      @ec2.wait_until(:volume_in_use, volume_ids: [volume.id])
      volume
    end

    def delete_volume(volume)
      volume.delete
      @ec2.wait_until(:volume_deleted, volume_ids: [volume.id])
      volume
    end

    def get_latest_snapshot
      snapshots = @volume.snapshots
      unless snapshots.any?
        raise "No snapshots for volume #{@volume.id} found, aborting restore process.\nHint: have you created a snapshot for this volume at least once?"
      end
      snapshots.max_by{|ss|
        tags_hash = Hash[ss.tags.map{|t| [t.key, t.value]}]
        Date.parse(tags_hash[EXPIRES_ON_KEY]) rescue Date.new
      }
    end

    def create_volume(snapshot, volume_type: 'gp2')
      resp = @ec2.create_volume(
        snapshot_id: snapshot.id,
        availability_zone: @availability_zone,
        volume_type: volume_type)
      volume = Aws::EC2::Volume.new(resp.volume_id)
      @ec2.wait_until(:volume_available, volume_ids: [resp.volume_id])
      volume
    end
  end
end
