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

Work in progress

## Contributing

1. Fork it ( http://github.com/<my-github-username>/fallout/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
