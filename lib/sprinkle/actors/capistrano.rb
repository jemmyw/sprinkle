require 'capistrano/cli'

module Sprinkle
  module Actors
    # = Capistrano Delivery Method
    #
    # Capistrano is one of the delivery method options available out of the
    # box with Sprinkle. If you have the capistrano gem install, you may use
    # this delivery. The only configuration option available, and which is 
    # mandatory to include is +recipes+. An example:
    #
    #   deployment do
    #     delivery :capistrano do
    #       recipes 'deploy'
    #     end
    #   end
    #
    # Recipes is given a list of files which capistrano will include and load.
    # These recipes are mainly to set variables such as :user, :password, and to 
    # set the app domain which will be sprinkled. 
    class Capistrano
      attr_accessor :config, :loaded_recipes #:nodoc:

      def initialize(&block) #:nodoc:
        @config = ::Capistrano::Configuration.new
        @config.logger.level = Sprinkle::OPTIONS[:verbose] ? ::Capistrano::Logger::INFO : ::Capistrano::Logger::IMPORTANT
        @config.set(:password) { ::Capistrano::CLI.password_prompt }
        @name_counters = Hash.new { |h, v| h[v] = 0 }
        
        if block
          self.instance_eval(&block)
        else
          @config.load 'deploy' # normally in the config directory for rails
        end
      end

      # Defines a recipe file which will be included by capistrano. Use these
      # recipe files to set capistrano specific configurations. Default recipe
      # included is "deploy." But if any other recipe is specified, it will
      # include that instead. Multiple recipes may be specified through multiple
      # recipes calls, an example:
      #
      #   deployment do
      #     delivery :capistrano do
      #       recipes 'deploy'
      #       recipes 'magic_beans'
      #     end
      #   end
      def recipes(script)
        @loaded_recipes ||= []
        @config.load script
        @loaded_recipes << script
      end
      
      def find_servers(roles)
        @config.find_servers(:roles => roles).collect(&:host)
      end

      def process(name, commands, server, suppress_and_return_failures = false) #:nodoc:        
        task = task_sym(name)
                
        define_task(task, server) do
          via = fetch(:run_method, :sudo)
          commands.each do |command|
            invoke_command command, :via => via
          end
        end        

        begin
          run(task)
    
          return true
        rescue ::Capistrano::CommandError => e
          return false if suppress_and_return_failures

          # Reraise error if we're not suppressing it
          raise
        end        
      end          
      
      def put(name, uploads, roles, suppress_and_return_failures = false) #:nodoc:                
        task = task_sym(name)        
        
        define_task(task, roles) do
          uploads.each do |file, upload|
            put upload[:content], file, upload[:options]
          end
        end
        
        begin
          run(task)
    
          return true
        rescue ::Capistrano::CommandError => e
          return false if suppress_and_return_failures

          # Reraise error if we're not suppressing it
          raise
        end        
      end

      private

        # REVISIT: can we set the description somehow?
        def define_task(name, server, &block)
          @config.task name, :hosts => server, &block
        end

        def run(name)
          @config.find_and_execute_task(name)
        end

        def task_sym(name)
          "install_#{name.to_task_name}_#{@name_counters[name] += 1}" #.to_sym
        end
    end
  end
end


=begin

# channel: the SSH channel object used for this response
# stream: either :err or :out, for stderr or stdout responses
# output: the text that the server is sending, might be in chunks
run "apt-get update" do |channel, stream, output|
   if output =~ /Are you sure?/
     answer = Capistrano::CLI.ui.ask("Are you sure: ")
     channel.send_data(answer + "\n")
   else
     # allow the default callback to be processed
     Capistrano::Configuration.default_io_proc.call[channel, stream, output]
   end
 end



 You can tell subversion to use a different username+password by
 setting a couple variables:
    set :svn_username, "my svn username"
    set :svn_password, "my svn password"
 If you don't want to set the password explicitly in your recipe like
 that, you can make capistrano prompt you for it like this:
    set(:svn_password) { Capistrano::CLI.password_prompt("Subversion
 password: ") }
 - Jamis
=end
