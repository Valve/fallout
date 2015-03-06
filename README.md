# Fallout

Really easy Amazon EC2 backup/restore solution.


## Installation

    $ gem install fallout

## Usage

This gem installs `fallout` executable. Don't forget to run `rbenv`
rehash, if you're on rbenv.
You must have `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
environment variables set to authenticate with EC2.

Fallout supports 2 commands:

### backup

Syntax:

`fallout backup -v <volume_id> -k <keep_days>`

Example:

```
$ fallout backup -v vol-23ab3d -k 7

 Deleted snapshots snap-6695b3a5, snap-ca6a3069
 Created new snapshot snap-b67f7725, expires after 2014-09-14
```

_This will create a snapshot for the specified volume and will mark it
as valid for 7 days. It will also delete all expired snapshots, created for the
specified volume._

#### How does expiration work?

When creating a snapshot, `fallout` will tag it with a special
`expires_after` tag. When running the backup, `fallout` will search for
any expired snapshots and remove them. This way you can have `fallout`
running every day, it will keep N most fresh snapshots automatically.

### restore

Restoring is a one-liner too.

Syntax:

`fallout restore -i <instance_id> -v <volume_id>`

Example:

```
$ fallout restore -i i-f7850bda -v vol-72436837

Shutting down your instance.
Shut down instance successfully: i-f7850bda, status: stopped
Detached volume vol-72436837 from instance i-f7850bda successfully
Created new volume from the latest snapshot (vol-3942697c)
Attached new volume to instance
Successfully restored and started the instance with the new volume
Instance public hostname: ec2-54-165-20-157.compute-1.amazonaws.com
You may want to delete the old, detached volume vol-72436837 and old volume snapshots
IMPORTANT: You must update your backup command to use new volume_id: vol-3942697c
```

#### How does restoring work?

Restoring with fallout requires you to have at least 1 snapshot for the
volume. The process will shutdown the instance, detach the root volume,
create new volume from the latest snapshot and attach it as `/dev/sda1`
device. Then the process will boot the instance with the new volume and
display its public hostname.

##### IMPORTANT:

Currently the volume will be attached as `/dev/sda1` device and created
in `us-east-1a` zone.
If you need this stuff to be configurable, let me know, I'll implement
it.

#### General considerations:

I created this gem purely for my own purposes, we only have a handful of
EC2 instances and the gem is working fine for us.

I run `fallout backup` daily with cron.

Contributions, tips/advices and pull requests are welcome.

### Licence

This code is MIT licenced:

Copyright (c) 2014 Valentin Vasilyev

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/fallout/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
