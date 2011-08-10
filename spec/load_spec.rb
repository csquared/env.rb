require_relative '../lib/env'

describe Env, '::load!' do
  def envfile(string)
    File.open("Envfile", 'w') do |f|
      f << string
    end
  end

  after { Env.unload }

  context "with no Envfile" do
    it "should return false" do
      Env.load!.should be_false
    end
  end

  context "with a simple Envfile" do
    before do
      envfile(%{
        export 'FOO', 'bar'
      })
    end

    after { File.unlink('Envfile') }

    it "should return true" do
      Env.load!.should be_true
    end

    it "should load Envfile in this directory" do
      Env.load!
      Env.enforce
      ENV['FOO'].should == 'bar'
    end 
  end
end
