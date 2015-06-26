require 'pear_warranty'
require 'bundler/setup'
require 'webmock/rspec'
Bundler.setup
WebMock.disable_net_connect!

def spec_folder
  File.expand_path '..', __FILE__
end

def mock_request(proxy, imei, name)
  proxy_url = "https://#{PearWarranty::PROXIES[proxy]}.proxfree.com/request.php?do=go"
  args =  {allowCookies: 'on', pfipDropdown: "default", pfserverDropdown: proxy_url}
  stub_request(:post, proxy_url).
      with(body: args.merge(get: "https://selfsolve.apple.com/wcResults.do?sn=#{imei}&Continue=Continue&num=0")).
      to_return(
      :status => 200,
      :body => File.open(spec_folder + "/support/#{name}.html")
  )
end

def mock_all_request(imei, name, without_body = true)
  if without_body
    stub_request(:post, /https\:\/\/(#{class1::PROXIES.join('|')})\.proxfree\.com\/request\.php\?do=go/).
        to_return(:status => 200, :body => File.open(spec_folder + "/support/#{name}.html"))
  else
    PearWarranty::PROXIES.size.times do |p|
      mock_request(p,imei, name)
    end
  end
end