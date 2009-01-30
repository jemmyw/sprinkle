require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Config do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_config(&block)
    Sprinkle::Installers::Config.new(@package, &block)
  end

  describe 'during initialization' do

    before do
      @installer = create_config do
        put "hello.txt", 'world'
      end
      @installer_with_options = create_config do 
        put "hello.txt", 'world', :mode => 755
      end
    end

    it 'should store content in a pending hash' do
      @installer.pending_uploads.has_key?('hello.txt').should == true
      @installer.pending_uploads['hello.txt'].should == {:content => 'world', :options => {}}
    end
    
    it 'should accept upload options' do
      @installer_with_options.pending_uploads['hello.txt'].should == {:content => 'world', :options => {:mode => 755} }      
    end

  end
  
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
    
    
  end
end
