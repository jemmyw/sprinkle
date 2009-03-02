require File.dirname(__FILE__) + '/../../spec_helper'

#
# I'm not good at rspec. These need to be refactored. 
#
#
#

describe Sprinkle::Installers::Config do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_config(&block)
    Sprinkle::Installers::Config.new(@package, &block)
  end

  describe 'during initialization' do

    describe 'with file uploads' do 
      before do
        @installer = create_config do
          put "hello.txt", 'world'
        end
        @installer_with_options = create_config do 
          put "hello.txt", 'world', :mode => 755
        end
      end

      it 'should store upload content in a pending uploads hash' do
        @installer.pending_uploads.has_key?('hello.txt').should == true
        @installer.pending_uploads['hello.txt'].should == {:content => 'world', :options => {}}
      end
    
      it 'should accept upload options' do
        @installer_with_options.pending_uploads['hello.txt'].should == {:content => 'world', :options => {:mode => 755} }      
      end
    end
    
    describe 'with commands' do 
      before do 
        @installer = create_config do
          run "echo 'hello'"
        end
      end
      
      it 'should store commands in a pending commands hash' do
        @installer.pending_commands.size.should == 1
        @installer.pending_commands.first.should == "echo 'hello'"
      end
      
    end

  end
  
  # now it get's ugly. 
  # extract the creation of an installer object
  
  describe 'during processing' do
    include Sprinkle::Deployment
    
    before do
      @deployment = deployment do
        delivery :capistrano
      end
      @installer = create_config do
        put "hello.txt", 'world'
        pre :install, "echo 'pre install'"
        pre :config, "echo 'pre config'"
        post :install, "echo 'post install'"
        post :config, "echo 'post config'"
      end
      @installer.defaults(@deployment)
      @delivery = @deployment.style
    end
    
    it "should allow run pre :install/:config commands" do
      @installer.pre_config_commands.should == ["echo 'pre install'","echo 'pre config'"]
    end
    it "should allow run post :install/:config commands" do
      @installer.post_config_commands == ["echo 'post install'","echo 'post config'"]
    end
    
    
    describe 'with file uploads' do
      it 'should upload files if present' do
        deployment = deployment do
          delivery :capistrano
        end
        installer = create_config do
          put "hello.txt", 'world'
        end
        installer.defaults(@deployment)
        delivery = @deployment.style
        delivery.should_receive(:put).with("package", {"hello.txt" => {:content => "world", :options => {}}}, :app)
        installer.process(:app)
      end
      
      it 'should run pre/post :upload commands' do
        deployment = deployment do
          delivery :capistrano
        end
        installer = create_config do
          put "hello.txt", 'world'
          pre :upload, "pre upload"
          post :upload, "post upload"
        end
        installer.defaults(@deployment)
        delivery = @deployment.style
        delivery.should_receive(:put)
        delivery.should_receive(:process).with("package", ["pre upload"], :app)
        delivery.should_receive(:process).with("package", ["post upload"], :app)
        installer.process(:app)
      end
    end
    
    describe 'with commands' do 
      before do
        @deployment = deployment do
          delivery :capistrano
        end
        @installer = create_config do
          pre :commands, "pre"
          run "command"
          post :commands, "post"
        end
        @installer.defaults(@deployment)
        @delivery = @deployment.style
      end
      
      it 'should process commands' do
        @delivery.should_receive(:process).with("package",["pre", "command", "post"], :app)
        @installer.process(:app)
      end
      
      it 'should run pre/post :commands commands' do
        @installer.config_command_sequence.should == ["pre", "command", "post"]
      end
    end
    
    
  end
end
