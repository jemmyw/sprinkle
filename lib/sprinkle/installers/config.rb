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
      attr_accessor :package, :delivery, :pending_uploads, :pending_commands #:nodoc:

      def initialize(package, &block) #:nodoc:
        @pending_uploads = {}
        @pending_commands = []
        super package, &block
      end                   
      
      def put(file, content, options={})
        @pending_uploads[file] = {:content => content, :options => options}
      end         
      
      def put_file(file, source, options={})
        put(file,open(source).read,options)
      end
      
      def run(command)
        @pending_commands << command
      end
      
      def process(roles) #:nodoc:
        assert_delivery

        if logger.debug?
          logger.debug "#{@package.name} uploading: #{@pending_uploads.keys.join(", ")} for roles: #{roles}\n"
          logger.debug "#{@package.name} running config commands: #{config_command_sequence.join(", ")} for roles: #{roles}\n"
        end

        unless Sprinkle::OPTIONS[:testing]
          logger.info "--> #{@package.name} running config for: #{roles}"
          logger.info "    uploading: #{@pending_uploads.keys.join(", ")}" unless @pending_uploads.keys.blank?
          
          #pre commands
          @delivery.process(@package.name, pre_config_commands, roles) unless pre_config_commands.blank?
          
          # uploads with pre :upload and post :upload callbacks ( put(...) )
          @delivery.process(@package.name, pre_commands(:upload), roles) unless pre_commands(:upload).blank?
          @delivery.put(@package.name, @pending_uploads, roles) unless @pending_uploads.blank?
          @delivery.process(@package.name, post_commands(:upload), roles) unless post_commands(:upload).blank?
          
          unless config_command_sequence.blank?
            # commands ( run(...) )
            logger.info "    commands: #{config_command_sequence.join(", ")}"
            @delivery.process(@package.name, config_command_sequence, roles) 
          end
          
          # post commands
          @delivery.process(@package.name, post_config_commands, roles) unless post_config_commands.blank?
        end
        
      end

      def pre_config_commands
        pre_commands(:install) + pre_commands(:config)
      end
    
      def post_config_commands
        post_commands(:install) + post_commands(:config)
      end
      
      def config_command_sequence
        commands = pre_commands(:commands) + @pending_commands + post_commands(:commands)
        commands.flatten
      end
    end
  end
end
