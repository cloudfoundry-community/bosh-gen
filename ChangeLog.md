Change Log
==========

v0.19.0

-	`cli-plugin` - generates a BOSH CLI plugin stub (Ruby code)

v0.18.0

-	`errand` - generates an errand-style job template
-	`copy_property` helper now in bosh-templates gem
-	`manifest` - `resource_pools` no longer specifies a `size` (modern BOSH has auto-sizing) (v0.18.1)
-	`manifest` - use modern flexible `jobs.templates` format (v0.18.2)

v0.17.0
-------

-	`new` - no more read-only credentials; no more encryption keys
-	`new` - no more --s3/--swift flags; prompts instead
-	`share release` - easily upload a final release and get a public URL to share (v0.17.1)

v0.16.0
-------

-	`new` creates an initial job of the same name.
-	default to running job process as vcap:vcap [v0.16.1]
-	Default $INCLUDE_PATH & $LD_LIBRARY_PATH to '' if not set [v0.16.1]
-	Fix make_manifest for aws-ec2 [v0.16.2]
-	Remove references to OpenStack until we have spiff templates generated [v0.16.2]

The initial job is configured to have the xyz.leader_address property, and an example conf file that shows how to use it.

v0.15.0
-------

-	Create packages from existing Aptitude .deb packages with `package --apt`
-	Assume project & job names have hyphens in templates
-	Templates default to latest stemcell [Aristoteles Neto]

v0.14.0
-------

-	templates/make_manifest & example spiff templates generated
-	no more static example bosh-lite.yml templates

v0.13.0
-------

-	bosh-lite example manifests generated for new releases
-	created folder always has -boshrelease suffix [v0.13.1]
-	use public https in generated readme [v0.13.2]
-	bosh-lite-solo.yml is a template [v0.13.3]

v0.12.0
-------

-	Supports bosh_cli 1.5.0.pre gems
-	dev.yml uses same release name as final.yml for blob reuse
-	sets reuse_compilation_vms: true now
-	generated project README focuses on final releases [v0.12.1]
-	Default bucket name is project folder name [v0.12.1]

v0.11.0
-------

Added:

-	New blobstore provider: OpenStack Swift [thanks Ferran!]
-	`package` --src/-s specifies already internal sources/blobs; example: --src 'myapp/\**/*'
-	`job` includes an empty `templates/config` to suggest where config templates should go

Improved:

-	`new` - --s3 flag looks for `~/.bosh_s3_credentials` file for default AWS S3 credentials

For common defaults on s3 blobstore credentials, create an`~/.bosh_s3_credentials` file that looks like:

```yaml
readonly_access_key: XXX
readonly_secret_access_key: XXX
readwrite_access_key: XXX
readwrite_secret_access_key: XXX
```

Other changes:

-	Using 1.0 release candidate for bosh_cli
-	`micro` - fix accidental gitignore of prepare/prepare_spec
-	`new` - `bosh-gen new project-boshrelease`; name is "project", initial dev name is "project-dev"
-	`manifest` - default stemcell is bosh-stemcell-0.6.4
-	`manifest` - creates `#{name}.yml` instead of `#{name}/manifest.yml`
-	`job` - example file not in a subfolder anymore

v0.10.0
-------

Added:

-	`micro` - create a "micro" job that packages all/some jobs into a single VM

Improved:

-	`new` - read/write credentials now in private.yml; more useful default README

v0.9.0
------

Major news

-	`job` - more powerful initial scripts; templates nested in folders; scripts are much cleaner to read; scripts in bin/ & helpers/ do not have ERb; only data/properties.sh.erb & config/ are for ERb.

Other changes:

-	`package` - detects .zip files (in addition to .tar.gz) and includes useful default unpacking script in `packaging`; describe available env vars in `packaging` script
-	`manifest` - auto-detects current BOSH UUID
-	`extract-pkg` - now a single argument - the path of the source package folder
-	`extract-job` - now a single argument - the path of the source job folder

v0.8.0
------

Changed:

-	`package` - the `packaging` script include default tar/configure/make sequence for all tarballs

For example, `bosh-gen package nginx -f ..../blobs/nginx/`, the resulting `packaging` is:

```bash
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

-	`extract-job` & `extract-pkg` - copies files mentioned in specs
-	`package` - large files go into blobs/ folder

### v0.8.2

Bug fixes:

-	`extract-pkg` - missing #source_file helper

v0.7.0
------

Added:

-	`extract-pkg` - extract a package and its dependencies from a target release

Changed/Renamed:

-	`extract` -> `extract-job`
-	`new` -> `.gitignore` includes `.vagrant`, to support `bosh-solo`
-	`manifest` -> update to soon-to-be-released stemcell 0.6.2

v0.6.0
------

Added:

-	`extract` - extract a job and its dependent packages to the current release

### v0.6.1

-	`new` - ignore .blobs folder in releases
-	`manifest` - persistent_disk is an integer; added to common job too

### v0.6.2

-	`manifest` - provided IP addresses are distributed across jobs until it runs out
-	`manifest` - fix to allocation of persistent disk

v0.5.0
------

-	`job` - takes a COMMAND argument
-	`source --blob/-b` - file stored in blobs/ folder instead of src/
-	`source` - packaging script includes standard configure/make/make install if .tar.gz or .tgz

v0.4
----

-	`job` - added --ruby flag to include a ruby/rack-specifc ctl script
-	releases include a rake task to document what properties are required
-	`manifest` - has a --disk/-d flag to assign a persistent disk to all VMs (common pool)
-	`job` - export some variables in ctl scripts so they are available to application
-	`job` - ctl script has logs/tail/clearlogs commands

v0.3
----

Added:

-	`template` - add a template/file to a job
-	`source` - download and add a source file/tarball to a package

### v0.3.1 (never released)

Added:

-	`manifest` - generate a deployment manifest for a release

Fixed:

-	`job` - creates a monit script and a stub control script

### v0.3.2

-	`job` - ctl file has TODO to remind about PID file
-	`job` - use the provided release path to detect jobs

### v0.3.3

-	`manifest` - introspect the release project for release + job information

### v0.3.4

-	`manifest` - Force us-east-1e to ensure all VMs and volumes are always in the same AZ

v0.2
----

Added:

-	`package` - create package scaffold, including source files
-	`job` - create job scaffold

v0.1
----

-	`new` - create new release
