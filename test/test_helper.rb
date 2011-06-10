require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'simplenote'
%w(httparty fakeweb base64 vcr).each { |x| require x }
FakeWeb.allow_net_connect = false

VCR.config do |c|
  c.cassette_library_dir = File.join(File.expand_path('..', __FILE__), 'fixtures')
  c.http_stubbing_library = :fakeweb
end