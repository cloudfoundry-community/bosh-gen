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
```

TODO:

```
$ bosh-gen job somejob
$ bosh-gen package somepackage -u somejob
$ bosh-gen package anotherpackage
$ bosh-gen job anotherjob -u somepackage anotherpackage
```

This will create two jobs and two package scaffolds. Both packages will be used by `somejob`, and `anotherpackage` is used by both jobs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
