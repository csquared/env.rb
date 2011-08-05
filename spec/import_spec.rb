require_relative '../lib/env'

describe Env, 'import' do
  def envfile(string)
    File.open("Envfile", 'w') do |f|
      f << string
    end
  end

  context "with an import statement" do
    before do
      ENV['FOO'] = 'bar'
      envfile(%{
        import 'FOO'
      })
      Env.load!
    end

    it "should use the value in the ENV" do
      ENV['FOO'].should == 'bar'
    end
  end
end
