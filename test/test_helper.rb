require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'simplenote'
%w(httparty matchy fakeweb mocha base64 crack).each { |x| require x }
FakeWeb.allow_net_connect = false

class Test::Unit::TestCase
end
