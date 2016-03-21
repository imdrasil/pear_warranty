require 'pear_warranty'
require 'bundler/setup'
require 'webmock/rspec'

Bundler.setup
WebMock.disable_net_connect!

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random
  Kernel.srand config.seed
end

def spec_folder
  File.expand_path '..', __FILE__
end

def all_proxies_regexp
  %r{https\://(#{PearWarranty::Configure::AVAILABLE_PROXIES.join('|')})\.proxfree\.com/request\.php\?do=go}
end

def mock_request(proxy, imei, name)
  proxy_url = "https://#{proxy}.proxfree.com/request.php?do=go"
  args = { allowCookies: 'on', pfipDropdown: 'default', pfserverDropdown: proxy_url }
  stub_request(:post, proxy_url)
    .with(body: args.merge(get: "https://selfsolve.apple.com/wcResults.do?sn=#{imei}&Continue=Continue&num=0"))
    .to_return(status: 200, body: File.open(spec_folder + "/support/#{name}.html"))
end

def mock_all_request(imei, name, without_body = true)
  if without_body
    stub_request(:post, all_proxies_regexp)
      .to_return(status: 200, body: File.open(spec_folder + "/support/#{name}.html"))
  else
    PearWarranty::Configure::AVAILABLE_PROXIES.each { |p| mock_request(p, imei, name) }
  end
end
