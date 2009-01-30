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
    end

    it 'should store content in a pending hash' do
      @installer.pending_uploads.has_key?('hello.txt').should == true
      @installer.pending_uploads['hello.txt'].should == 'world'
    end

  end
end
