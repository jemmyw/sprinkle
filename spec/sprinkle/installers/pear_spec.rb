require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Pear do
  before do
    @pear = 'Log'
    @pear2 = 'Test'
  end

  describe 'with one package' do
    before do
      @package = mock(Sprinkle::Package, :name => 'pear test', :source => nil, :repository => nil)
      @installer = Sprinkle::Installers::Pear.new(@package, @pear)
    end

    it 'should accept a single package to install' do
      @installer.packages.should == [@pear]
    end
  end

  describe 'with two packages' do
        before do
      @package = mock(Sprinkle::Package, :name => 'pear test', :source => nil, :repository => nil)
      @installer = Sprinkle::Installers::Pear.new(@package, @pear, @pear2)
    end

    it 'should accept two packages to install' do
      @installer.packages.should == [@pear, @pear2]
    end
  end

  describe 'during installation' do
    before do
      @package = mock(Sprinkle::Package, :name => 'pear test', :source => nil, :repository => nil)
      @installer = Sprinkle::Installers::Pear.new(@package, @pear, @pear2) do
        pre :install, 'op1'
        post :install, 'op2'
      end
    end

    it 'should invoke the pear installer for the specified package' do
      @installer.send(:install_commands).should == "pear install Log Test"
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', "pear install #{@pear} #{@pear2}", 'op2']
    end
  end
end
