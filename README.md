BOSH Generators
===============

Generators for creating and sharing BOSH releases.

New in 0.20: Create packages from embedded Docker images

New in 0.17: Creates blobstore/bucket when creating new release. AWS bucket is publicly readable.

If you would like to share your BOSH release with the world, you can use the [BOSH Community AWS S3 account](#share-bosh-releases).

![example](http://f.cl.ly/items/3v2F43020a3N0Q1g3Z0E/bosh-gen-new.gif)

Installation
------------

This application requires Ruby 1.9 or 2.0 and is installed via RubyGems:

```
$ gem install bosh-gen
```

Usage
-----

```
$ bosh-gen new $(whoami)-project
      create  
Auto-detected infrastructure API credentials at ~/.fog (override with $FOG)
1. AWS (community)
2. Alternate credentials
Choose an auto-detected infrastructure: 2
Choose AWS region: 1

      create  README.md
      create  Rakefile
      create  jobs
      create  jobs/my-project/templates/bin/my_project_ctl
      ...
      create  config/blobs.yml
      create  config/dev.yml
      create  config/private.yml
      create  config/final.yml
      create  .gitignore
         run  git init from "."

Next, change to BOSH release location:
cd ./my-project-boshrelease

Finally...
Attempting to create blobstore my-project-boshrelease... done

Confirming: Using blobstore my-project-boshrelease
```

Your project is now in the folder mentioned above:

```
$ cd ./my-project-boshrelease
```

```
$ wget -P /tmp http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz
$ bosh-gen package ruby -f /tmp/ruby-2.2.2.tar.gz

$ bosh-gen job some-ruby-job -d ruby

$ bosh create release --force
```

To test out each iteration of your release, you can create a manifest, upload your release, and deploy it:

```
./templates/make_manifest warden
bosh upload release
bosh -n deploy
```

The large ruby tarball is automatically placed in the `blobs/` folder. Before you share your boshrelease with other developers you will want to sync it to your blobstore (the S3 bucket created via `bosh-gen new`\):

```
$ bosh upload blobs
```

Quickly creating packages
-------------------------

There is a slow way to create a package, and there are three faster ways. Slow vs fast is not a debated about best vs worse. But sometimes you're in a hurry.

### Slow way

```
$ bosh-gen package apache2
create  packages/apache2/packaging
create  packages/apache2/spec
```

The slowest way to create a package is to run the command above, then get the source, read the "install from source" instructions, and create a package.

### Slightly faster way

As above, when we created the `ruby` package we included a pre-downloaded asset:

```
$ bosh-gen package ruby -f /tmp/ruby-2.2.2.tar.gz
```

If you download the source files first, and reference them with the `bosh-gen package` generator, then it will attempt to guess how to install the package. The generated `packaging` script will include some starting commands that might work.

The command above will also copy the target file into the `blobs/ruby/` folder. One less thing for you to do.

You still need to look up "how to install from source" instructions and put them in `packages/ruby/packaging` script.

### Fastest way - reuse existing packages

```
$ bosh-gen extract-pkg ../cf-release/packages/postgres
```

The fastest way is to reuse an existing, working package from another BOSH release that you have on your local machine.

This command will copy across the `packages/postgres/spec` & `packages/postgres/packaging` files, as well as any blobs or src files that are referenced in the original BOSH release.

This is a great command to use. There are a growing number of BOSH releases on GitHub from which to steal, err, extract packages into your own BOSH releases.

Remember, first run `bosh sync blobs` in the target BOSH release project. Otherwise it will not be able to copy over the blobs.

### Fast way - embedded Docker images

This use case assumes you have `docker` CLI installed and access to a Docker daemon.

It will also make your BOSH release dependent upon the [cf-platform-eng/docker-boshrelease](https://bosh.io/d/github.com/cf-platform-eng/docker-boshrelease) release which installs the Docker daemon on VMs; and offers a simple way to run Docker containers if required.

```
$ bosh-gen package tmate --docker-image nicopace/tmate-docker
       exist  jobs
      create  jobs/nicopace_tmate_docker_image/monit
      create  jobs/nicopace_tmate_docker_image/spec
      create  jobs/nicopace_tmate_docker_image/templates/bin/install_ctl
      create  jobs/nicopace_tmate_docker_image/templates/bin/monit_debugger
      create  jobs/nicopace_tmate_docker_image/templates/helpers/ctl_setup.sh
      create  jobs/nicopace_tmate_docker_image/templates/helpers/ctl_utils.sh
       exist  packages
      create  packages/tmate/packaging
      create  packages/tmate/spec
docker pull nicopace/tmate-docker
Pulling repository nicopace/tmate-docker
7b9df453c66b: Download complete
...
6df853718c80: Download complete
Status: Image is up to date for nicopace/tmate-docker:latest
docker save nicopace/tmate-docker > blobs/docker-images/nicopace_tmate_docker.tgz

$ bosh create release --force
...
Release name: tmate-server
Release version: 0+dev.1
```

The `package --docker-image` flag will display the next steps help as well:

```
Next steps:
  1. To use this BOSH release, first upload it and the docker release to your BOSH:
    bosh upload release https://bosh.io/releases/cloudfoundry-community/consul-docker
    bosh upload release https://bosh.io/d/github.com/cf-platform-eng/docker-boshrelease

  2. To use the docker image, your deployment job needs to start with the following:

    jobs:
    - name: some_job
    templates:
      # run docker daemon
      - {name: docker, release: docker}
      # warm docker image cache from bosh package
      - {name: nicopace_tmate_docker_image, release: tmate-server}

  3. To simply run a single container, try the 'containers' job from 'docker' release

    https://github.com/cloudfoundry-community/consul-docker-boshrelease/blob/master/templates/jobs.yml#L18-L40
```

### Fast way - reuse Aptitude/Debian packages

```
$ bosh-gen package apache2 --apt
$ vagrant up
$ vagrant ssh -c '/vagrant/src/apt/fetch_debs.sh apache2'
$ vagrant destroy
```

You can add/change the Debian packages to install by editing `src/apt/apache2/aptfile` and re-running the `fetch_debs.sh` command above. You might want to delete `blobs/apt/apache2` first to ensure that only the fetched `.deb` files are subsequently included during package compilation.

It is possible now to download one or more `.deb` files into the `blobs/apt/` folder, and have them installed during package compilation time.

The installed .deb packages will be available at `/var/vcap/packages/apache2/apt`; rather than within the root folder system.

Your job monit control scripts can source a provided `profile.sh` to setup environment variables:

```
source /var/vcap/packages/apache2/profile.sh
```

This is the last option, and it is not the best option. Many Debian packages will also start processes that have default configuration that is not correct for your use case. It may be fast to get the Debian packages; but additional work may be required by your jobs to stop and unhook the processes that are automatically started upon installation.

Tutorial
--------

To see how the various commands work together, let's create a new bosh release for [Cassandra](http://cassandra.apache.org/).

```
$ bosh-gen new cassandra
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
```

Look at all that goodness!

A quick summary of these files:

-	The `monit` script uses `bin/monit_debugger` to help you debug any glitches in starting/stopping processes.
-	`ctl_setup.sh` setups up lots of common folders and env vars.
-	`ctl_utils.sh` comes from cf-release's common/utils.sh with some extra helper functions
-	`data/properties.sh.erb` is where you extract any `<%= properties.cassandra... %>` values from the deployment manifest.
-	`bin/cassandra_ctl` no longer needs to be an unreadable ERb template! Use the env variables you create in `data/properties.sh.erb` and normal bash if statements instead of ERb `<% if ... %>` templates.
-	`examples/...` is a folder for documenting example, valid deployment manifest properties for the release.

In `bin/cassandra_ctl` you now change "TODO" to `cassandra` and the rest of the tutorial is left to you, dear cassandra lover.

Your release is now ready to build, test and deploy:

```
bosh create release --force
bosh upload release
```

When you create a final release, you will first need to setup your AWS credentials in `config/final.yml`

Share BOSH releases
-------------------

To share your BOSH release with other BOSH users you need ONLY:

-	Use a public blobstore (such as AWS S3)
-	Use a public source control repository
-	Optionally, publicly share pre-created final release tarballs via a HTTP URL.

### Share release tarballs via HTTP

bosh-gen includes a BOSH CLI plugin to upload dev or final tarballs to your blobstore, and get a public URL back (if supported by your blobstore)

```
$ bosh create release --with-tarball
$ bosh share release releases/my-project-1.tgz
https://my-project-boshrelease.s3.amazonaws.com/boshrelease-my-project-1.tgz
```

The URL is displayed and can be given to other users and uploaded directly to their BOSH:

```
$ bosh upload release https://my-project-boshrelease.s3.amazonaws.com/boshrelease-my-project-1.tgz
```

They no longer require your BOSH release repo to access the BOSH release.

![share-http-tarball](http://f.cl.ly/items/0R3A1w3k2E3h3a2d1g2U/bosh-gen-share-release.gif)

### BOSH community facilities

You are welcome to re-use the BOSH user community facilities:

-	Use the shared AWS S3 account (currently over 30 BOSH release blobstores).
-	Place your release git repository in the [@cloudfoundry-community](https://github.com/cloudfoundry-community) GitHub account (over 50 people have access).

One time only, please email [Dr Nic Williams](mailto:&#x64;&#x72;&#x6E;&#x69;&#x63;&#x77;&#x69;&#x6C;&#x6C;&#x69;&#x61;&#x6D;&#x73;&#x40;&#x67;&#x6D;&#x61;&#x69;&#x6C;&#x2E;&#x63;&#x6F;&#x6D;) and he will set you up with access:

-	Read/write credentials to the AWS S3 account for your BOSH release blobstores/buckets
-	Access to create [@cloudfoundry-community](https://github.com/cloudfoundry-community) GitHub repositories for your BOSH releases

When he gives you the AWS S3 credentials, place them in the `~/.fog` file and you'll easily be able to reuse them for each new BOSH release:

```yaml
:community:
  :aws_access_key_id:     ACCESS
  :aws_secret_access_key: SECRET
```

Then for your next BOSH release:

```
$ bosh-gen new my-project
      create  
Auto-detected infrastructure API credentials at ~/.fog (override with $FOG)
1. AWS (community)
2. Alternate credentials
Choose an auto-detected infrastructure: 2
```

You'll only need to do this once. Yes, it would be awesome if there was some public service to do this nicely. Want to build it?

Create BOSH CLI plugins
-----------------------

You can now (v0.19.0+) quickly create a BOSH CLI plugin within a RubyGem (to share), BOSH workspace or release (local to that project).

Inside your RubyGem, BOSH workspace or release:

```
$ bosh-gen cli-plugin setup-deployment
    create  lib
    create  lib/bosh/cli/commands/setup_deployment.rb
```

The `setup_deployment.rb` file will now be automatically picked up by `bosh` CLI locally OR if you distribute your project as a RubyGem:

```
$ bosh setup deployment
WARNING: loading local plugin: lib/bosh/cli/commands/setup_deployment.rb
TODO
```

Note: the hyphenated name `setup-deployment` becomes a space-separated command `setup deployment`.

Contributing
------------

1.	Fork it
2.	Create your feature branch (`git checkout -b my-new-feature`\)
3.	Commit your changes (`git commit -am 'Added some feature'`\)
4.	Push to the branch (`git push origin my-new-feature`\)
5.	Create new Pull Request
