require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Custom do
  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_custom(command, &block)
    Sprinkle::Installers::Custom.new(@package, command, &block)
  end

  describe 'during installation' do
    before do
      @installer = create_custom 'adduser test' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the rpm installer for all specified packages' do
      @install_commands.should =~ /adduser test/
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', 'adduser test', 'op2' ]
    end
  end
end
