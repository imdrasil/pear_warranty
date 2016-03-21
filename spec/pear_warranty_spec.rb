require 'rspec'
require 'spec_helper'

RSpec.describe PearWarranty::Parser do
  let(:class1) { described_class }
  let(:configs) { PearWarranty::Configure }

  before { class1.instance_variable_set('@_agent', nil) }

  context '#to_boolean' do
    it 'should return true if argument is "true"' do
      expect(class1.send(:to_boolean, 'true')).to be true
    end

    it 'should return false with "false" argument' do
      expect(class1.send(:to_boolean, 'false')).to be false
    end

    it 'should return false with "asd" argument' do
      expect(class1.send(:to_boolean, 'asd')).to be false
    end
  end

  context '#get_form' do
    let(:proxy) { 'qc' }
    let(:value) { 'value' }
    let(:apple_url) { "https://selfsolve.apple.com/wcResults.do?sn=#{value}&Continue=Continue&num=0" }
    subject(:form) { class1.send(:get_form, proxy, value) }

    it 'returns Mechanize::Form object' do
      expect(form).to be_instance_of(Mechanize::Form)
    end

    it 'returns form with correct form attributes' do
      expect([form.action, form.name, form.send(:method)])
        .to eq([described_class.send(:get_url, proxy), 'main_submission', 'POST'])
    end

    it 'returns form with important fields' do
      h = 'hidden'
      url = class1.send(:get_url, proxy)
      array = [
        [h, 'pfserverDropdown', url],
        [h, 'allowCookies', 'on'],
        [h, 'pfipDropdown', 'default'],
        ['text', 'get', apple_url]
      ]
      expect(form.fields.map { |f| [f.type, f.name, f.value] }).to eq(array)
    end
  end

  context '#set_cookie' do
    let(:cookies) do
      class1.send(:set_cookie)
      class1.send(:_agent).cookies
    end
    let(:domain) { 'proxfree.com' }

    it 'should add to agent needed number of cookies' do
      expect(cookies.size).to eq(configs.cookies.size)
    end

    it 'should add cookies with correct domain' do
      expect(cookies.map { |c| c.domain }).to eq(Array.new(configs.cookies.size) { domain })
    end

    it 'should add cookies with correct path' do
      expect(cookies.map { |c| c.path }).to eq(Array.new(configs.cookies.size) { '/' })
    end

    it 'should add cookies with correct names and values' do
      values = configs.cookies.map { |k, v| [k, v] }
      expect(cookies.map { |c| [c.name, c.value] }).to eq(values)
    end
  end

  context '#check', type: :request do
    let(:date) { Date.new(2016, 6, 10) }
    let(:without_imei) { '013896000639712' }
    let(:with_imei) { '013977000323877' }
    let(:uncorrect_imei) { '1a312312312312' }
    let(:fake_imei) { 'fake_date_to_reproduse_behaviour' }
    let(:without_params) { [without_imei, 'without_warranty'] }
    let(:with_params) { [with_imei, 'with_warranty'] }
    let(:uncorrect_params) { [uncorrect_imei, 'uncorrect_warranty'] }
    let(:fake_params) { [fake_imei, 'proxy_error'] }
    let(:default_proxy) { 'qc' }

    it 'should use given proxy' do
      mock_request(default_proxy, *uncorrect_params)
      class1.check(uncorrect_imei, {}, default_proxy)
      expect(WebMock).to have_requested(:post, "https://#{default_proxy}.proxfree.com/request.php?do=go")
    end

    it 'should use random proxy if no one is given' do
      mock_all_request(fake_imei, fake_params[1])
      class1.check(fake_imei)
      expect(a_request(:post, all_proxies_regexp)).to have_been_made.times(10)
    end

    it 'return hash with keys :date and :warranty' do
      mock_request(default_proxy, *without_params)
      expect(class1.check(without_imei, {}, default_proxy).keys).to include(:warranty, :date)
    end

    it 'return hash with true for :warranty and correct date for :date for imei with warranty' do
      mock_request(default_proxy, *with_params)
      expect(class1.check(with_imei, {}, default_proxy)).to include(warranty: true, date: date)
    end

    it 'return hash with false for :warranty and nil for :date for imei without warranty' do
      mock_request(default_proxy, *without_params)
      expect(class1.check(without_imei, {}, default_proxy)).to include(warranty: false, date: nil)
    end

    it 'return hash with :error key and message if there is no such key in service' do
      mock_request(default_proxy, *uncorrect_params)
      expect(class1.check(uncorrect_imei, {}, default_proxy).keys).to include(:error)
    end

    it 'should make maximum number of tries if an error is occurred' do
      mock_all_request(fake_imei, fake_params[1])
      class1.check(fake_imei)
      expect(a_request(:post, all_proxies_regexp)).to have_been_made.times(PearWarranty::Configure.max_retries)
    end

    it 'should return hash with :error key if there is problem with proxy' do
      mock_all_request(fake_imei, fake_params[1])
      expect(class1.check(fake_imei).keys).to include(:error)
    end
  end
end
