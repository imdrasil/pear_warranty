require "pear_warranty/version"
require 'mechanize'

module PearWarranty

  TRIES = 10
  PROXIES = ['qc', 'de', 'al', 'nl', 'fr', 'no', 'tx', 'nj', 'il', 'ga'  ]
  COOKIES = {'_ga' => 'GA1.2.343285711.1435218476', '_gat' => '1', 's' => '3fd5f4953c541474c867c23b28853ad2', 'token' => 'acc1de9efdac455d'}

  def self.check(serial, proxy_index = nil)
    agent = Mechanize.new
    proxies = [0,1,2,3,4,5,6,7,8,9]
    unless proxy_index
      proxy_index = rand(PROXIES.size)
    else
      proxies -= [proxy_index]
    end
    page = nil
    error = true
    apple_url = "https://selfsolve.apple.com/wcResults.do?sn=#{serial}&Continue=Continue&num=0"
    correct_reg = /warrantyPage\.warrantycheck\.displayHWSupportInfo/
    invalid_reg = [/but this serial number is not valid/, /but the serial number you have provided cannot be found in our records/]
    TRIES.times do
      form = get_form(proxy_index, apple_url, agent)
      set_cookie(agent)
      begin
        page = agent.submit(form)
      rescue Net::HTTP::Persistent::Error
        proxy_index = proxies[rand(proxies.size)]
        proxies -= [proxy_index]
        next
      end
      page = page.body
      if page =~ correct_reg or page =~ invalid_reg[1] or page =~ invalid_reg[0]
        error = false
        break
      end
      proxy_index = proxies[rand(proxies.size)]
      proxies -= [proxy_index]
    end
    if error
      {error: 'Problem with proxy'}
    else
      unless page =~ correct_reg
        { error: 'There is no such imei or service is not available at this moment' }
      else
        text = page.split(correct_reg)[1].scan(/\(.*\)/)[0].delete('()')
        params = text.split(', ')
        warranty = to_boolean(params.first.delete ' ')
        {
            warranty: warranty,
            date: (Date.parse(params[2][/Estimated Expiration Date: (.*)/, 1] + ' ' + params[3][0..3]) if warranty)
        }
      end
    end
  end

  private

  def self.get_url(proxy)
    "https://#{PROXIES[proxy] || PROXIES[0]}.proxfree.com/request.php?do=go"
  end

  def self.to_boolean(str)
    str == 'true'
  end

  def self.get_form(proxy, value, agent)
    url = get_url(proxy)
    builder = Nokogiri::HTML::Builder.new do |doc|
      doc.form_ :method=>'POST', :action=>url, name: 'main_submission' do
        doc.input :type=>'hidden', :name=>'pfserverDropdown', :value => url
        doc.input :type=>'hidden', :name=>'allowCookies', :value => 'on'
        doc.input :type=>'hidden', :name=>'pfipDropdown', :value => 'default'
        doc.input type: 'text', name: 'get', value: value
      end
    end
    node = Nokogiri::HTML(builder.to_html)
    form = Mechanize::Form.new(node.at('form'), agent)
    form
  end

  def self.set_cookie(agent)
    COOKIES.each_pair do |k,v|
      cookie = Mechanize::Cookie.new(k, v)
      cookie.domain = '.proxfree.com'
      cookie.path = '/'
      agent.cookie_jar.add(cookie)
    end
  end

end
