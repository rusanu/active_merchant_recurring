require 'active_support/concern'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module PaypalRecurring #:nodoc:
      extend ActiveSupport::Concern

      @__add_payment_details_suppressed = false

      RECURRING_PAYMENTS = "RecurringPayments"

      included do
        alias_method :old_add_payment_details, :add_payment_details

        def add_payment_details(xml, money, currency_code, options={})
          old_add_payment_details xml, money, currency_code, option unless @__add_payment_details_suppressed
        end
 
        # Create a recurring payment.
        #
        # This transaction creates a recurring payment profile.
        # See https://developer.paypal.com/docs/classic/paypal-payments-pro/integration-guide/WPRecurringPayments/
        # ==== Parameters
        #
        # * <tt>amount</tt> -- The amount to be charged to the customer at each interval as an Integer value in cents.
        # * <tt>token</tt> -- The token obtained with a pervious SetExpressCheckout call
        # * <tt>options</tt> -- A hash of parameters.
        #
        # ==== Options
        #
        # * <tt>:period</tt> -- [Day, Week, SemiMonth, Month, Year] default: Month
        # * <tt>:frequency</tt> -- a number
        # * <tt>:cycles</tt> -- Limit to certain # of cycles (OPTIONAL)
        # * <tt>:start_date</tt> -- When does the charging starts (REQUIRED)
        # * <tt>:description</tt> -- The description to appear in the profile (REQUIRED)

        def create_recurring_profile(amount, token, options = {})

          options[:amount] = amount
          options[:token] = token
          requires!(options, :token,  :start_date, :period, :frequency, :amount)
          commit 'CreateRecurringPaymentsProfile', build_create_profile_request(options)
        end

      end

      def setup_recurring(options = {})
        requires!(options, :return_url, :cancel_return_url, :billing_agreement)
        requires!(options[:billing_agreement], :description)
        options[:billing_agreement][:type] = RECURRING_PAYMENTS

        @__add_payment_details_suppressed = true
        begin
          request =  build_setup_request('Authorization', 0, options)
        ensure
          @__add_payment_details_suppressed = false
        end

        commit 'SetExpressCheckout',  request
        end

    end
  end
end

if defined?(ActiveMerchant::Billing::PaypalExpressGateway)
  ActiveMerchant::Billing::PaypalExpressGateway.send(:include, ActiveMerchant::Billing::PaypalRecurring)
end
