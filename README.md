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
$ bosh create release

$ wget -P /tmp http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz 
$ bosh-gen package ruby -f /tmp/ruby-1.9.3-p194.tar.gz

$ bosh-gen package some-package -d ruby
$ bosh-gen package some-other-package -d ruby

$ bosh-gen job some-ruby-job -d some-package some-other-package
```


This will create one job, which depends on three packages (`some-package`, `some-other-package` and ultimately also `ruby`).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
