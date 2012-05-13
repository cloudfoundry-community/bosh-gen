# Change Log

## v0.6.0

Added:

* `extract` - extract a job and its dependent packages to the current release

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