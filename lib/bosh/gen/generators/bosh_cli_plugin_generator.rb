require 'thor/group'
require 'active_support/core_ext/string'

module Bosh::Gen
  module Generators
    class BoshCliPluginGenerator < Thor::Group
      include Thor::Actions

      argument :plugin_name

      def self.source_root
        File.join(File.dirname(__FILE__), "bosh_cli_plugin_generator", "templates")
      end

      def install_plugin
        directory "lib"
      end

      private
      def underscore_plugin_name
        plugin_name.gsub(/\W+/, '_')
      end

      def spaced_plugin_name
        plugin_name.gsub(/\W+/, ' ')
      end

      def camelcase_plugin_name
        underscore_plugin_name.camelcase
      end
    end
  end
end
