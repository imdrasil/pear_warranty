module PearWarranty
  # THis class implements gathering of all configuration for scrapping
  class Configure
    AVAILABLE_PROXIES = %w(qc def al nl fr no tx nj il ga).freeze
    ALLOWED_ORDERS = [:random, :given].freeze
    DEFAULT_VALUES = {
      default_proxy: 'qc',
      use_list: AVAILABLE_PROXIES,
      switch_proxy: true,
      max_retries: 10,
      switch_order: :random,
      cookies: {
        '_ga' => 'GA1.2.343285711.1435218476',
        '_gat' => '1',
        's' => '3fd5f4953c541474c867c23b28853ad2',
        'token' => 'acc1de9efdac455d'
      }, # TODO: refactor this to autofetching
      ok_response_pattern: /warrantyPage\.warrantycheck\.displayHWSupportInfo/,
      bad_response_pattern:
        /(but this serial number is not valid)|(but the serial number you have provided cannot be found in our records)/
    }.freeze

    class << self
      attr_accessor :default_proxy, :use_list, :switch_proxy, :max_retries, :switch_order, :cookies,
                    :ok_response_pattern, :bad_response_pattern

      DEFAULT_VALUES.each do |field, value|
        define_method(field) do
          instance_variable_set("@#{field}", value) if instance_variable_get("@#{field}").nil?
          instance_variable_get("@#{field}")
        end
      end

      def initialize(attrs)
        attrs.each { |k, v| send("#{k}=", v) }
      end

      def default_proxy=(value)
        @default_proxy = if AVAILABLE_PROXIES.include? value
                           value
                         else
                           log(:default_proxy, AVAILABLE_PROXIES.first)
                           AVAILABLE_PROXIES.first
                         end
      end

      def use_list=(value)
        @use_list = value.map { |e| e.downcase }.select { |e| AVAILABLE_PROXIES.include? e }
        return @use_list unless @use_list.empty?
        log(:use_list)
        @use_list = DEFAULT_VALUES[:use_list]
      end

      def switch_order=(value)
        return @switch_order = value if ALLOWED_ORDERS.include? value
        log(:switch_order)
        @switch_order = DEFAULT_VALUES[:switch_order]
      end

      def patterns
        [ok_response_pattern, bad_response_pattern]
      end

      def config
        yield self
      end

      def proxy_valid?(name)
        !name.nil? && AVAILABLE_PROXIES.include?(name)
      end

      private

      def log(*attrs)
        case attrs[0]
        when :default_proxy
          warn "Given proxy are not allowed. Switched to '#{attrs[1]}'"
        end if $VERBOSE
      end
    end
  end
end
