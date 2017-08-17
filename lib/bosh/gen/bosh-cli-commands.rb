module Bosh
  module Gen
    class BoshCli
      # BoshCli.run("add-blob #{source_path} #{target_path}")
      def self.run(command)
        `#{cli_name} #{command}`
      end

      def self.cli_name
        @@cli_name ||= begin
          `which bosh2`.size == 0 ? "bosh" : "bosh2"
        end
      end
    end
  end
end
