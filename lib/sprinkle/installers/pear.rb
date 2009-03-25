module Sprinkle
  module Installers
    # = Pear Package Installer
    #
    class Pear < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, *packages, &block) #:nodoc:
        packages.flatten!

        options.update(packages.pop) if packages.last.is_a?(Hash)

        super parent, options, &block

        @packages = packages
      end

      protected

      def install_commands #:nodoc:
        "pear install #{@packages.join(' ')}"
      end
    end
  end
end
