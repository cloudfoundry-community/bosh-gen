# Change Log

## v0.8.0

Changed:

* `package` - the `packaging` script include default tar/configure/make sequence for all tarballs

For example, `bosh-gen package nginx -f ..../blobs/nginx/`, the resulting `packaging` is:

``` bash
set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables

export HOME=/var/vcap

tar xzf nginx/nginx-1.2.0.tar.gz
cd nginx-1.2.0
./configure --prefix=${BOSH_INSTALL_TARGET}
make
make install
```

### v0.8.1

Changed:

* `extract-job` & `extract-pkg` - copies files mentioned in specs
* `package` - large files go into blobs/ folder

### v0.8.2

Bug fixes:

* `extract-pkg` - missing #source_file helper

## v0.7.0

Added:

* `extract-pkg` - extract a package and its dependencies from a target release

Changed/Renamed:

* `extract` -> `extract-job`
* `new` -> `.gitignore` includes `.vagrant`, to support `bosh-solo`
* `manifest` -> update to soon-to-be-released stemcell 0.6.2

## v0.6.0

Added:

* `extract` - extract a job and its dependent packages to the current release

### v0.6.1

* `new` - ignore .blobs folder in releases
* `manifest` - persistent_disk is an integer; added to common job too

### v0.6.2

* `manifest` - provided IP addresses are distributed across jobs until it runs out
* `manifest` - fix to allocation of persistent disk

## v0.5.0

* `job` - takes a COMMAND argument
* `source --blob/-b` - file stored in blobs/ folder instead of src/
* `source` - packaging script includes standard configure/make/make install if .tar.gz or .tgz

## v0.4

* `job` - added --ruby flag to include a ruby/rack-specifc ctl script
* releases include a rake task to document what properties are required
* `manifest` - has a --disk/-d flag to assign a persistent disk to all VMs (common pool)
* `job` - export some variables in ctl scripts so they are available to application
* `job` - ctl script has logs/tail/clearlogs commands

## v0.3

Added:

* `template` - add a template/file to a job
* `source` - download and add a source file/tarball to a package

### v0.3.1 (never released)

Added:

* `manifest` - generate a deployment manifest for a release

Fixed:

* `job` - creates a monit script and a stub control script

### v0.3.2

* `job` - ctl file has TODO to remind about PID file
* `job` - use the provided release path to detect jobs

### v0.3.3

* `manifest` - introspect the release project for release + job information

### v0.3.4

* `manifest` - Force us-east-1e to ensure all VMs and volumes are always in the same AZ

## v0.2

Added:

* `package` - create package scaffold, including source files
* `job` - create job scaffold

## v0.1

* `new` - create new release