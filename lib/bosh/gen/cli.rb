require 'thor'

module Bosh
  module Gen
    class Command < Thor
      include Thor::Actions
    
      desc "new NAME", "Creates a new BOSH release"
      method_option :s3, :alias => ["--aws"], :type => :boolean, :desc => "Use AWS S3 bucket for blobstore"
      method_option :atmos, :type => :boolean, :desc => "Use EMC ATMOS for blobstore"
      def new(name)
        flags = { :aws => options["s3"], :atmos => options["atmos"] }
        
        require 'bosh/gen/generators/new_release_generator'
        Bosh::Gen::Generators::NewReleaseGenerator.start([name, flags])
      end

      no_tasks do
        def cyan; "\033[36m" end
        def clear; "\033[0m" end
        def bold; "\033[1m" end
        def red; "\033[31m" end
        def green; "\033[32m" end
        def yellow; "\033[33m" end
      end
    end
  end
end
