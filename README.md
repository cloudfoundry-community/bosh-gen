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

## Creating a new BOSH release

The `bosh-gen new [name]` subcommand is where you get started. It will create a `name-boshrelease` folder in your local directory filled with everything to make a working BOSH release (that doesn't do anything):

```plain
bosh-gen new my-system
```

You will be prompted for your AWS credentials. If you have a `~/.fog` file, then it will allow you to pick on of those credential pairs. Yes, I should add support for `~/.aws/credentials` too. Yes, I should add support for GCP bucket stores too.

A new AWS S3 bucket will be created for you called `my-system-boshrelease`, and am S3 policy will be attached to make its contents publicly readable to your BOSH release users.

An initial BOSH deployment manifest will be provided that "just works". Try it out:

```plain
export BOSH_DEPLOYMENT=my-system
bosh deploy manifests/my-system.yml
```

This will create/package your BOSH release, upload it to your BOSH environment, and deploy an VM that does nothing. But you're up and running and can now iterate towards your final BOSH release.
