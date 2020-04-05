# Rapid generation of BOSH releases

Generators for creating, updating, and sharing BOSH releases.

The https://bosh.io documentation includes a long guide to [explaining BOSH releases and how to create them](https://bosh.io/docs/create-release/). The `bosh-gen` project boosts your speed and guides you towards some newer best practises (e.g. BPM for jobs).

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

* An initial `README.md` for your users (please keep this updated with any instructions specific to your release and deployment manifests)
* 0 packages
* 1 job called `my-system` with an empty `monit` file
* 1 deployment manifest `manifests/my-system.yml` with `version: create` set so that every `bosh deploy` will always create/upload a new version of your release during initial development
* Some sample operator files that you or your users might use to deploy your BOSH release
* `config/final.yml` describes your public S3 bucket
* `config/private.yml` is your local-only private AWS API credentials
* `config/blobs.yml` will be updated when you run `bosh add-blob` to add 3rd-party blobs into your project

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

## Jobs and packages

When you're finished and have a working BOSH release, base deployment manifest (`manifests/my-system.yml`), and optional operator files (`manifests/operators`) your BOSH release will include one or more jobs, and one or more packages.

I personally tend to iterate by writing packages first, getting them to compile, and then writing jobs to configure and run the packaged software. So I'll suggest this approach to you.

## Writing a package

Helpful commands from `bosh-gen`:

* `bosh-gen package name` - create a `packages/name` folder with initial `spec` and `packaging` file
* `bosh-gen extract-pkg /path/to/release/packages/name` - import a package folder from other BOSH release on your local machine, and its blobs and src files.

The `bosh` CLI also has helpful commands to create/borrow packages:

* `bosh generate-package name` - create a `packages/name` folder with initial `spec` and `packaging` file
* `bosh vendor-package name /path/to/release` - import the final release of a package from other BOSH release ([see blog post](https://starkandwayne.com/blog/build-bosh-releases-faster-with-language-packs/)), not the source of the package and its blobs.

The `bosh` CLI also has commands for adding/removing blobs:

* `bosh add-blob`
* `bosh remove-blob`

Let's create a `redis` package a few different ways to see the differences.

## Vendoring a package from another release

If there is another BOSH release that has a package that you want, consider vendoring it.

There is already a [redis-boshrelease](https://github.com/cloudfoundry-community/redis-boshrelease) with a `redis-4` package.

```plain
mkdir ~/workspace
git clone https://github.com/cloudfoundry-community/redis-boshrelease ~/workspace/redis-boshrelease

bosh vendor-package redis-4 ~/workspace/redis-boshrelease
```

This command will download the final release version of the `redis-4` package from the `redis-boshrelease` S3 bucket, and then upload it to your own BOSH release's S3 bucket:

```plain
-- Finished downloading 'redis-4/5c3e41...'
Adding package 'redis-4/5c3e41...'...
-- Started uploading 'redis-4/5c3e41...'
2018/04/18 08:18:25 Successfully uploaded file to https://s3.amazonaws.com/my-system-boshrelease/108682c9...
-- Finished uploading 'redis-4/5c3e41...'
Added package 'redis-4/5c3e41...'
```

It will then reference this uploaded blob with the `packages/redis-4/spec.lock` file in your BOSH release project folder.

To include the `redis-4` package in your deployment, it needs to be referenced by a job.

Change `jobs/my-system/spec` YAML file's `packages` section to reference your `redis-4` package:

```yaml
---
name: my-system
packages: [redis-4]
templates:
  ignoreme: ignoreme
properties: {}
```

Now re-deploy to see your `redis-4` package compiled:

```plain
bosh deploy manifests/my-system.yml
```

The output will include:

```plain
Task 4550 | 12:24:46 | Compiling packages: redis-4/5c3e41... (00:00:57)
```

We can `bosh ssh` into our running `my-system` instance to confirm that `redis-server` and `redis-cli` binaries are available to us:

```plain
bosh ssh
```

Inside the VM, list the binaries that have been installed with our package:

```plain
$ ls /var/vcap/packages/redis-4/bin
redis-benchmark  redis-check-aof  redis-check-rdb  redis-cli  redis-sentinel  redis-server
```

A note in advance for writing our BOSH job, these binaries are not in the normal `$PATH` location. They are in `/var/vcap/packages/redis-4` folder.

## Upgrading a vendored package

If you're vendoring another release's package, you will need to keep an eye on updates and to re-vendor them into your release.

Essentially, you will re-clone or update the upstream release locally, and re-run `bosh vendor-package`:

```plain
mkdir ~/workspace
git clone https://github.com/cloudfoundry-community/redis-boshrelease ~/workspace/redis-boshrelease

bosh vendor-package redis-4 ~/workspace/redis-boshrelease
```

## Hard-forking another package

You might like to start with other BOSH release's package and make changes (for example, change the upstream blobs or modify the compilation flags).

The `bosh-gen extract-pkg` command is very helpful here. It will copy not just the `packaging` script, but also any blobs or source files from the target BOSH release.

Let's replace our vendored package with a hard fork using `bosh-gen extract-pkg`:

```plain
pushd ~/workspace/redis-boshrelease
bosh sync-blobs
popd

rm -rf packages/redis-4/spec.lock
bosh-gen extract-pkg ~/workspace/redis-boshrelease/packages/redis-4
```

The output will show that your BOSH release now has its own `redis.tgz` blob:

```plain
       exist  packages/redis-4
      create  packages/redis-4/packaging
       chmod  packages/redis-4/packaging
      create  packages/redis-4/spec
       chmod  packages/redis-4/spec
    add-blob  redis/redis-4.0.9.tar.gz
      readme  Upload blobs with 'bosh upload-blobs'
```

Your BOSH release now has a `packages/redis-4/packaging` script to describe how to convert the `redis/redis-4.0.9.tar.gz` file into the compiled `redis-server`, `redis-cli` binaries we saw earlier.

You can now edit `packages/redis-4/packaging` to modify the `make install` flags etc if you want.

The `redis/redis-4.0.9.tar.gz` blob has been copied into the `blobs` folder:

```plain
$ tree blobs
blobs
└── redis
    └── redis-4.0.9.tar.gz
```

Or you can change the `redis/redis-4.0.9.tar.gz` blob. Visit http://download.redis.io/releases/ and find a newer release (or older release) and download it.

First, remove the current blob:

```plain
bosh remove-blob redis/redis-4.0.9.tar.gz
```

Next, add the new blob:

```plain
bosh add-blob ~/Downloads/redis-4.0.8.tar.gz redis/redis-4.0.8.tar.gz
```

As early, to create/upload/deploy your new package:

```plain
bosh deploy manifests/my-system.yml
```

So that other developers can access your BOSH releases you need to upload your blobs to your S3 bucket:

```plain
bosh upload-blobs
```

Your uploaded blobs are referenced in `config/blobs.yml`:

```yaml
redis/redis-4.0.8.tar.gz:
  size: 1729973
  object_id: 9c954728-d998-459f-7be5-27b8de003b29
  sha: f723b327022cef981b4e1d69c37a8db2faeb0622
```

## Create package from scratch

There is something unique and special about your BOSH release. Probably you have some bespoke software you want to deploy.

There are some core components to a bespoke package:

* `blobs` - yet-to-be-compiled or precompiled assets that are cached within your S3 blobstore, rather than inside your BOSH release
* `src` - git submodules to your bespoke code repositories
* `packages/name/packaging` - bash script to compile and prepare the package for runtime environments; this script is run within a BOSH compilation VM during `bosh deploy`

If your bespoke software is already being compiled from an internal team, then you can use the `bosh remove-blob` and `bosh add-blob` combo discussed in the preceding section.

More commonly, you will include your bespoke project via a `git submodule` in the `src` folder, and then delegate the compilation and preparation to your BOSH package's `packaging` script.

I've written up a blob article/tutorial for submoduling bespoke projects, using language packs (`bosh vendor-package`), and packaging your bespoke app at https://www.starkandwayne.com/blog/build-bosh-releases-faster-with-language-packs/.

## Running things with Jobs

The ultimate goal of your deployment manifest is to describe a set of VMs that have installed software that is configured and running.

A deployment manifest describes a common groups of VMs as an "instance group", which includes one or more jobs from BOSH releases. When you ran `bosh-gen new` an initial deployment manifest was generated that references a single job:

```yaml
instance_groups:
- name: my-system
  instances: 1
  jobs:
  - name: my-system
    release: my-system
    properties: {}
  ...
```

The `release: my-system` references an uploaded BOSH release that is described at the bottom of the manifest:

```yaml
releases:
- name: bpm
  version: 1.1.8
  url: git+https://github.com/cloudfoundry/bpm-release
- name: my-system
  version: create
  url: file://.
```

Later, when you've created your first final BOSH release, you will update this `releases:` section from `version: create` to `version: 1.0.0` to reference your final release version.

The `jobs: [{name: my-system, release: my-system}]` reference in the manifest describes the `jobs/my-system` folder in our BOSH release.

In the initial `bosh-gen new` scaffold, a relatively empty `jobs/my-system` folder was provided so that `bosh deploy` initially works.

The `jobs/my-system/monit` file describes all running processes for a job. In the initial scaffold generated this file is empty.

We want to add a `redis` process to our VM, so let's create a `redis` job.

```plain
bosh-gen job redis -d redis-4
```

The output shows that a `config/bpm.yml` file is created.

The `monit` file is now updated to create/monitor a Linux process using BPM:

```plain
check process my-system
  with pidfile /var/vcap/sys/run/bpm/my-system/my-system.pid
  start program "/var/vcap/jobs/bpm/bin/bpm start my-system"
  stop program "/var/vcap/jobs/bpm/bin/bpm stop my-system"
  group vcap
```
