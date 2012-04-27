# BOSH Generators

Generators for creating BOSH releases.

## Installation

Add this line to your application's Gemfile:

    gem 'bosh-gen'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bosh-gen

## Usage

```
$ bosh-gen new my-new-project --s3
$ bosh-gen new my-new-project --atmos
$ bosh-gen new my-new-project # local blobstore with a warning

$ cd my-new-project
```

**NEXT:** Edit `config/final.yml` with your S3 or ATMOS credentials

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



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
