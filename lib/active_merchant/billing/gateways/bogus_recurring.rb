require 'active_support/concern'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module BogusGatewayRecurring #:nodoc:
      extend ActiveSupport::Concern

      BOGUS_GATEWAY_RECURRING_TOKEN = 'bogus_token'

      def setup_recurring(options = {})
        response = Response.new(true, ActiveMerchant::Billing::BogusGateway::SUCCESS_MESSAGE, {}, :test => true, :authorization => ActiveMerchant::Billing::BogusGateway::AUTHORIZATION)

        def response.token
          BOGUS_GATEWAY_RECURRING_TOKEN
        end

        response
      end

      def redirect_url_for(token)
        self.homepage_url
      end

      def create_recurring_profile(money, options = {})
        Response.new(true, ActiveMerchant::Billing::BogusGateway::SUCCESS_MESSAGE, {}, :test => true, :authorization => ActiveMerchant::Billing::BogusGateway::AUTHORIZATION)
      end

    end
  end
end

if defined?(ActiveMerchant::Billing::BogusGateway)
  ActiveMerchant::Billing::BogusGateway.send(:include, ActiveMerchant::Billing::BogusGatewayRecurring)
end
