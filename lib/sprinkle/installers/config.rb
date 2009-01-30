require 'open-uri'

module Sprinkle
  module Installers
    # = Config Installer
    #
    # Allows you to upload config files to the server
    # 
    # == Example Usage
    #
    #   config do
    #     put '/etc/apache2/ports.conf', 'Listen 8080'
    #   end
    #
    class Config < Installer
      attr_accessor :package, :delivery, :pending_uploads #:nodoc:

      def initialize(package, &block) #:nodoc:
        @pending_uploads = {}
        super package, &block
      end                   
      
      def put(file, content, options={})
        @pending_uploads[file] = {:content => content, :options => options}
      end         
      
      def put_file(file, source, options={})
        put(file,open(source).read,options)
      end
      
      def process(roles) #:nodoc:
        assert_delivery

        if logger.debug?
          pending = @pending_uploads.keys.join(", ");
          logger.debug "#{@package.name} uploading: #{pending} for roles: #{roles}\n"
        end

        unless Sprinkle::OPTIONS[:testing]
          pending = @pending_uploads.keys.join(", ");
          logger.info "--> #{@package.name} uploading for roles: #{roles}"
          logger.info "    #{pending}"
          @delivery.process(@package.name, pre_config_commands, roles)
          @delivery.put(@package.name, @pending_uploads, roles)
          @delivery.process(@package.name, post_config_commands, roles)
        end
        
      end

      def pre_config_commands
        pre_commands(:install) + pre_commands(:config)
      end
    
      def post_config_commands
        post_commands(:install) + post_commands(:config)
      end

    end
  end
end
