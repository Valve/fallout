module Fallout
  class Backup
    EXPIRES_ON_KEY = 'expires_on'.freeze

    include VolumeUtils

    def initialize(options)
      @volume_id = options[:volume]
      @keep = options[:keep].to_i
      @expires_on = Date.today + @keep
      @volume = verify_volume_or_raise(Aws::EC2::Volume.new(@volume_id))
    end

    def delete_expired_snapshots
      snapshots = @volume.snapshots
      snapshots = snapshots.map do |ss|
        begin
          tags_hash = Hash[ss.tags.map{|t| [t.key, t.value]}]
          expires_on = Date.parse(tags_hash[EXPIRES_ON_KEY])
          if expires_on < Date.today
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
      description = "Snapshot for volume #{@volume_id}, will be deleted on #{@expires_on}"
      snapshot = @volume.create_snapshot(description: description)
      snapshot.create_tags(tags: [{key: EXPIRES_ON_KEY, value: @expires_on.to_s}])
      [snapshot, @expires_on]
    end
  end
end
