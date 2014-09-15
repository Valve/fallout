module Fallout
  class Restore
    def initialize(options)
      @instance_id = options[:instance]
      @volume_id = options[:volume]
      @ec2 = AWS::EC2.new
      @ec2_client = AWS::EC2::Client.new
    end

    def get_volume
      @ec2.volumes[@volume_id]
    end

    def shutdown_instance
      instance = @ec2.instances[@instance_id]
      raise "Instance does not exist: #{@instance_id}" if instance.nil? || !instance.exists?
      instance.stop
      while instance.status != :stopped
        sleep 1
      end
      instance
    end

    def start_instance(instance)
      instance.start
      while instance.status != :running
        sleep 1
      end
      instance
    end

    def detach_volume(instance, device = '/dev/sda1')
      volume = @ec2.volumes[@volume_id]
      raise "Volume does not exist: #{volume_id}" if volume.nil? || !volume.exists?
      attachment = volume.detach_from(instance, device)
      while volume.status != :available
        sleep 1
      end
      attachment
    end

    def attach_volume(volume, instance, device = '/dev/sda1')
      volume.attach_to(instance, device)
      while volume.status != :in_use
        sleep 1
      end
      volume
    end

    def delete_volume(volume)
      volume.delete
      while volume.status != :deleted
        sleep 1
      end
      volume
    end

    def get_latest_snapshot_for_volume(volume)
      snapshots = @ec2.snapshots.filter('volume-id', @volume_id)
      raise "No snapshots for volume #{volume.id} found, aborting restore process.\n
      Hint: have you created a snapshot for this volume at least once?" unless snapshots.any?
      snapshots.max_by{|ss| Date.parse(ss.tags.to_h[EXPIRES_AFTER_KEY]) rescue Date.new}
    end

    def create_volume(snapshot, availability_zone = 'us-east-1a', volume_type: 'gp2')
      resp = @ec2_client.create_volume(
        snapshot_id: snapshot.id,
        availability_zone: availability_zone,
        volume_type: volume_type)
      volume = @ec2.volumes[resp[:volume_id]]
      while volume.status != :available
        sleep 1
      end
      volume
    end
  end
end
