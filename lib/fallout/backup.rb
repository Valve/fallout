require 'aws'
module Fallout
  class Backup
    EXPIRES_AFTER_KEY = 'expires_after'.freeze
    def initialize(options)
      @volume_id = options[:volume]
      @keep = options[:keep].to_i
      @expires_after = Date.today + @keep
      @ec2 = AWS::EC2.new
    end

    def delete_expired_snapshots
      snapshots = @ec2.snapshots.filter('volume-id', @volume_id)
      snapshots = snapshots.map do |ss|
        begin
          da = Date.parse(ss.tags.to_h[EXPIRES_AFTER_KEY])
          if da < Date.today
            ss.delete
            ss
          end
        rescue
          next
        end
      end
      snapshots.compact
    end

    def run
      @volume = @ec2.volumes[@volume_id]
      raise "Volume does not exist: #{@volume_id}" if @volume.nil? || !@volume.exists?
      desc = "Snapshot for volume #{@volume_id}, will be deleted after #{@expires_after}"
      snapshot = @volume.create_snapshot(desc)
      snapshot.add_tag(EXPIRES_AFTER_KEY, value: @expires_after.to_s)
      [snapshot, @expires_after]
    end
  end
end
