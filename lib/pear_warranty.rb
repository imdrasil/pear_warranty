require 'pear_warranty/version'
require 'pear_warranty/configure'
require 'mechanize'

module PearWarranty
  # This class provide scrapping functionality
  class Parser
    class << self
      def check(serial, cookies = {}, proxy_name = nil)
        page = try_get(serial, cookies, proxy_name)
        if page.nil?
          { error: 'Problem with proxy' }
        else
          extract_data_from_body(page)
        end
      ensure
        @_proxies = @_agent = nil
      end

      private

      def try_get(serial, cookies, proxy_name)
        page = nil
        last = PearWarranty::Configure.max_retries.times do
          page = _request(cookies, _next_proxy(proxy_name), serial)
          break if page
        end
        return page unless !last.nil? && last == PearWarranty::Configure.max_retries
      end

      def extract_data_from_body(page)
        if page =~ PearWarranty::Configure.bad_response_pattern
          { error: 'There is no such imei or service is not available at this moment' }
        else
          params = extract_params_from_text(page)
          warranty = to_boolean(params.first.delete(' '))
          { warranty: warranty, date: (parse_date(params) if warranty) }
        end
      end

      def parse_date(params)
        Date.parse(params[2][/Estimated Expiration Date: (.*)/, 1] + ' ' + params[3][0..3])
      end

      def extract_params_from_text(page)
        page.split(PearWarranty::Configure.ok_response_pattern)[1].scan(/\(.*\)/)[0].delete('()').split(', ')
      end

      def _request(cookies, proxy, sn)
        set_cookie(cookies)
        page = _agent.submit(get_form(proxy, sn)).body
        return page if PearWarranty::Configure.patterns.any? { |p| page =~ p }
      rescue Net::HTTP::Persistent::Error
      end

      def _proxies
        @_proxies = PearWarranty::Configure.use_list.dup if @_proxies.nil? || @_proxies.empty?
        @_proxies
      end

      def _next_proxy(proxy = nil)
        return proxy if PearWarranty::Configure.proxy_valid?(proxy)
        return PearWarranty::Configure.default_proxy unless PearWarranty::Configure.switch_proxy
        index = case PearWarranty::Configure.switch_order
                when :random
                  rand(_proxies.size)
                when :given
                  0
                end
        _proxies.delete_at(index)
      end

      def _agent
        @_agent ||= Mechanize.new
      end

      def get_url(proxy)
        "https://#{proxy}.proxfree.com/request.php?do=go"
      end

      def to_boolean(str)
        str == 'true'
      end

      def get_form(proxy, sn)
        node = Nokogiri::HTML(build_form(proxy, sn).to_html)
        Mechanize::Form.new(node.at('form'), _agent)
      end

      def build_form(proxy, value)
        apple_url = "https://selfsolve.apple.com/wcResults.do?sn=#{value}&Continue=Continue&num=0"
        url = get_url(proxy)
        Nokogiri::HTML::Builder.new do |doc|
          doc.form_ method: 'POST', action: url, name: 'main_submission' do
            doc.input type: 'hidden', name: 'pfserverDropdown', value: url
            doc.input type: 'hidden', name: 'allowCookies', value: 'on'
            doc.input type: 'hidden', name: 'pfipDropdown', value: 'default'
            doc.input type: 'text', name: 'get', value: apple_url
          end
        end
      end

      def set_cookie(cookies = {})
        _agent.cookie_jar.clear!
        PearWarranty::Configure.cookies.merge(cookies).each_pair do |k, v|
          cookie = Mechanize::Cookie.new(k, v)
          cookie.domain = '.proxfree.com'
          cookie.path = '/'
          _agent.cookie_jar.add(cookie)
        end
      end
    end
  end
end
