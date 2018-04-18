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

This will create/package your BOSH release, upload it to your BOSH environment, and deploy an VM that does nothing. 

```plain
Task 4525 | 10:56:28 | Creating missing vms: mything/27f862a1-a51b-468d-b3c5-35750eac483a (0) (00:00:15)
```

You're up and running and can now iterate towards your final BOSH release.

Your initial BOSH release scaffold includes:

* 0 packages
* 1 job called `my-system` with an empty `monit` file
* 1 deployment manifest `manifests/my-system.yml` with `version: create` set so that every `bosh deploy` will always create/upload a new version of your release during initial development
* Some sample operator files that you or your users might use to deploy your BOSH release

### BPM

It is assumed that you will be using BOSH Process Manager (BPM) to describe your BOSH jobs, so it has already been included in your deployment manifest. You will have seen it compiled during your initial `bosh deploy` above:

```plain
Task 4525 | 10:55:33 | Compiling packages: bpm-runc/c0b41921c5063378870a7c8867c6dc1aa84e7d85
Task 4525 | 10:55:33 | Compiling packages: golang/65c792cb5cb0ba6526742b1a36e57d1b195fe8be
Task 4525 | 10:55:51 | Compiling packages: bpm-runc/c0b41921c5063378870a7c8867c6dc1aa84e7d85 (00:00:18)
Task 4525 | 10:56:16 | Compiling packages: golang/65c792cb5cb0ba6526742b1a36e57d1b195fe8be (00:00:43)
Task 4525 | 10:56:16 | Compiling packages: bpm/b5e1678ac76dd5653bfa65cb237c0282e083894a (00:00:11)
```

You can see it included within your manifest's `addons:` section:

```yaml
addons:
- name: bpm
  jobs: [{name: bpm, release: bpm}]
```

It is possible that BPM will become a first-class built-in feature of BOSH environments in the future, and then this `addons` section can be removed. For now, it is an addon for your deployment manifest. BPM will make your life as a BOSH release developer easier.