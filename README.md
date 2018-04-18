# Rapid generation of BOSH releases

Generators for creating, updating, and sharing BOSH releases.

## Install

`bosh-gen` is distributed as a RubyGem:

```plain
gem install bosh-gen
```

## Requirements

When you run `bosh-gen new` to create a new BOSH release it will attempt to create an AWS S3 bucket to store your blobs, vendored packages (language packs), and final releases. You will need a AWS account and appropriate AWS keys.

If you'd like, contact [Dr Nic](mailto:drnic@starkandwayne.com) for credentials to the CF Community AWS account.