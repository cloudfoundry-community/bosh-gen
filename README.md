# BOSH Generators

Generators for creating BOSH releases.

## Installation

This application requires Ruby 1.9 or 2.0 and is installed via RubyGems:

$ gem install bosh-gen

## Usage

```
$ bosh-gen new my-new-project --s3
$ bosh-gen new my-new-project --atmos
$ bosh-gen new my-new-project --swift
$ bosh-gen new my-new-project # local blobstore with a warning

$ cd my-new-project
```

**NEXT:** Edit `config/final.yml` with your S3, ATMOS or Swift credentials

```
$ bosh create release

$ wget -P /tmp http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz 
$ bosh-gen package ruby -f /tmp/ruby-1.9.3-p194.tar.gz

$ bosh-gen job some-ruby-job -d ruby

$ git add .
$ git commit -m "added a job + 3 packages"

$ bosh create release
```

It is not ideal to include large source files, such as the 10Mb ruby tarball, in your git repository. Rather, use the blobstore for those:

```
$ rm -rf src/ruby/ruby-1.9.3-p194.tar.gz
$ bosh add blob /tmp/ruby-1.9.3-p194.tar.gz ruby
$ bosh upload blobs

$ bosh create release
```

Your job may need additional configuration files or executables installed.

```
$ bosh-gen template some-ruby-job config/some-config.ini
    create  jobs/some-ruby-job/templates/some-config.ini.erb
     force  jobs/some-ruby-job/spec
```

### Micro jobs - all-in-one VM

If your release includes two or more jobs you might want to offer a "micro" job that includes all/some jobs into a single VM.

To achieve this, there is a special `micro` generator.

```
$ bosh-gen micro
      create  jobs/micro
      create  jobs/micro/prepare
       chmod  jobs/micro/prepare
      create  jobs/micro/prepare_spec
      append  .gitignore

Edit jobs/micro/prepare_spec with ordered list of jobs to include
in micro job. The order of jobs implicitly specifies the order in
which they are started.
```

As above, now edit `prepare_spec` to order/restrict the list of jobs to be included in the micro VM.

Now create a new bosh release and a "micro/0.1-dev" job will be included:

```
$ bosh create release --force
...
Jobs
+----------+---------+-------+------------------------------------------+
| Name     | Version | Notes | Fingerprint                              |
+----------+---------+-------+------------------------------------------+
...
| micro    | 0.1-dev |       | 6eb2f98644ef7f61a0399c015cbe062987dfd498 |
+----------+---------+-------+------------------------------------------+
```

## Tutorial

To see how the various commands work together, let's create a new bosh release for [Cassandra](http://cassandra.apache.org/ "The Apache Cassandra Project").

```
$ bosh-gen new cassandra --s3
$ cd cassandra
$ bosh-gen extract-pkg ../cf-release/packages/dea_jvm7
      create  packages/dea_jvm7
      create  packages/dea_jvm7/packaging
      create  packages/dea_jvm7/spec
      create  blobs/java/jre-7u4-linux-i586.tar.gz
      create  blobs/java/jre-7u4-linux-x64.tar.gz
      readme  Upload blobs with 'bosh upload blobs'
$ mv packages/dea_jvm7 packages/java7
```

In `packages/java7/spec`, rename it to `java7`.

```
$ bosh-gen package cassandra -d java7 -f ~/Downloads/apache-cassandra-1.0.11-bin.tar.gz
      create  packages/cassandra/packaging
      create  blobs/cassandra/apache-cassandra-1.0.11-bin.tar.gz
      create  packages/cassandra/spec
```

Change `packages/cassandra/packaging` to:

```
tar xfv cassandra/apache-cassandra-1.0.11-bin.tar.gz
cp -a apache-cassandra-1.0.11/* $BOSH_INSTALL_TARGET
```

Now create a stub for running cassandra as a job:

```
$ bosh-gen job cassandra -d java7 cassandra
      create  jobs/cassandra
      create  jobs/cassandra/monit
      create  jobs/cassandra/templates/bin/cassandra_ctl
      create  jobs/cassandra/templates/bin/monit_debugger
      create  jobs/cassandra/templates/data/properties.sh.erb
      create  jobs/cassandra/templates/helpers/ctl_setup.sh
      create  jobs/cassandra/templates/helpers/ctl_utils.sh
      create  jobs/cassandra/spec
      create  examples/cassandra_simple
      create  examples/cassandra_simple/default.yml
```

Look at all that goodness!

A quick summary of these files:

* The `monit` script uses `bin/monit_debugger` to help you debug any glitches in starting/stopping processes.
* `ctl_setup.sh` setups up lots of common folders and env vars.
* `ctl_utils.sh` comes from cf-release's common/utils.sh with some extra helper functions
* `data/properties.sh.erb` is where you extract any `<%= properties.cassandra... %>` values from the deployment manifest.
* `bin/cassandra_ctl` no longer needs to be an unreadable ERb template! Use the env variables you create in `data/properties.sh.erb` and normal bash if statements instead of ERb `<% if ... %>` templates.
* `examples/...` is a folder for documenting example, valid deployment manifest properties for the release.

In `bin/cassandra_ctl` you now change "TODO" to `cassandra` and the rest of the tutorial is left to you, dear cassandra lover.

Your release is now ready to build, test and deploy:

```
bosh create release --force
bosh upload release
```

When you create a final release, you will first need to setup your AWS credentials in `config/final.yml`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
