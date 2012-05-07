require "minitest/spec"
require "minitest-colorize"
require "bosh/gen/models"

class BoshStatusSpec < MiniTest::Spec
  it "runs outside a release folder" do
    bosh_status = <<-OUT.gsub(/^\s{4}/, '')
    Updating director data... done

    Target         myfirstbosh (http://ec2-10-2-3-4.compute-1.amazonaws.com:25555) Ver: 0.5 (fc80a028)
    UUID           c897319f-9b4b-41ae-9ed7-7de00bXXXXXX
    User           drnic
    Deployment     /tmp/redis.yml

    OUT
    
    expected = {
      "Target" => {
        "name" => "myfirstbosh",
        "uri"  => "http://ec2-10-2-3-4.compute-1.amazonaws.com:25555"
      },
      "UUID" => "c897319f-9b4b-41ae-9ed7-7de00bXXXXXX",
      "User" => "drnic",
      "Deployment" => "/tmp/redis.yml"
    }
    
    Bosh::Gen::Models::BoshStatus.new.to_json.must_equal expected
  end
  
  it "fails nicely if 'bosh status' output has changed or isn't as expected" do
    bosh_status = "Something futuristic that bosh-gen doesn't know about"
    Bosh::Gen::Models::BoshStatus.new.to_json.must_raise Bosh::Gen::Models::BoshCliOutputChanged
  end
end
