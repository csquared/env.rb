require_relative '../lib/env'

describe Env, '::import' do
  def envfile(string)
    File.open("Envfile", 'w') do |f|
      f << string
    end
  end

  after do 
    File.unlink('Envfile')
    Env.unload
  end

  let(:rack) do
    %w{GEM_HOME TMPDIR HTTPS}
  end

  let(:heroku) do
    %w{TMP TEMP} + rack
  end

  context "import 'FOO'" do
    before do
      ENV['FOO'] = 'bar'
      envfile(%{
        import 'FOO'
      })
      Env.load!
    end

    it "should use the value in ENV['FOO']" do
      ENV['FOO'].should == 'bar'
    end
  end

  context "import :rack" do
    before do
      rack.each { |var| ENV[var] = 'foo' }
      envfile(%{
        import :rack
      })
      Env.load!
    end

    it "should import GEM_HOME, TMPDIR, and HTTPS" do
      rack.each do |var|
        lambda { ENV[var] }.should_not raise_error
      end
    end
  end

  context "import :heroku" do
    before do
      heroku.each { |var| ENV[var] = 'foo' }
      envfile(%{
        import :heroku
      })
      Env.load!
    end

    it "should import TMP, TEMP, and RACK" do
      heroku.each do |var|
        lambda { ENV[var] }.should_not raise_error
      end
    end
  end
end
