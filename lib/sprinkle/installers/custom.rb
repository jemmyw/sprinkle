module Sprinkle
  module Installers
    # = Custom Installer
    #
    # A really simple installer than just runs any commands
    #
    # == Example Usage
    #
    # Adding a user to passwd
    #
    #   package :deployment_user do
    #     custom 'useradd -d /home/deployer -s /usr/sbin/nologin deployer'
    #   end
    #
    class Custom < Installer
      def initialize(parent, command, &block) #:nodoc:
        options = {:command => command}
        super parent, options, &block
      end

      protected

      def install_commands #:nodoc:
        @options[:command]
      end
    end
  end
end