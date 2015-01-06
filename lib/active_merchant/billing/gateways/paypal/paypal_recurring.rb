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
          old_add_payment_details xml, money, currency_code, options unless @__add_payment_details_suppressed
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
          currency_code = options[:currency] || currency(amount)
          options[:amount] = amount
          options[:token] = token
          requires!(options, :token,  :start_date, :period, :frequency, :amount)
          commit 'CreateRecurringPaymentsProfile', build_create_profile_request_items(amount, currency_code, options)
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

      private

      def build_create_profile_request_items(money, currency_code, options)
       
        xml = Builder::XmlMarkup.new :indent => 2
        xml.tag! 'CreateRecurringPaymentsProfileReq', 'xmlns' => ActiveMerchant::Billing::PaypalCommonAPI::PAYPAL_NAMESPACE do
          xml.tag! 'CreateRecurringPaymentsProfileRequest', 'xmlns:n2' => ActiveMerchant::Billing::PaypalCommonAPI::EBAY_NAMESPACE do
            xml.tag! 'n2:Version', ActiveMerchant::Billing::PaypalCommonAPI::API_VERSION
            xml.tag! 'n2:CreateRecurringPaymentsProfileRequestDetails' do
              xml.tag! 'Token', options[:token] unless options[:token].blank?
              xml.tag! 'n2:RecurringPaymentsProfileDetails' do
                xml.tag! 'n2:BillingStartDate', (options[:start_date].is_a?(Date) ? options[:start_date].to_time : options[:start_date]).utc.iso8601
                xml.tag! 'n2:ProfileReference', options[:profile_reference] unless options[:profile_reference].blank?
              end
              xml.tag! 'n2:ScheduleDetails' do
                xml.tag! 'n2:Description', options[:description]
                xml.tag! 'n2:PaymentPeriod' do
                  xml.tag! 'n2:BillingPeriod', options[:period] || 'Month'
                  xml.tag! 'n2:BillingFrequency', options[:frequency]
                  xml.tag! 'n2:TotalBillingCycles', options[:total_billing_cycles] unless options[:total_billing_cycles].blank?
                  xml.tag! 'n2:Amount', amount(options[:amount]), 'currencyID' => options[:currency] || 'USD'
                  xml.tag! 'n2:TaxAmount', amount(options[:tax_amount] || 0), 'currencyID' => options[:currency] || 'USD' unless options[:tax_amount].blank?
                  xml.tag! 'n2:ShippingAmount', amount(options[:shipping_amount] || 0), 'currencyID' => options[:currency] || 'USD' unless options[:shipping_amount].blank?
                end
                if !options[:trial_amount].blank?
                  xml.tag! 'n2:TrialPeriod' do
                    xml.tag! 'n2:BillingPeriod', options[:trial_period] || 'Month'
                    xml.tag! 'n2:BillingFrequency', options[:trial_frequency]
                    xml.tag! 'n2:TotalBillingCycles', options[:trial_cycles] || 1
                    xml.tag! 'n2:Amount', amount(options[:trial_amount]), 'currencyID' => options[:currency] || 'USD'
                    xml.tag! 'n2:TaxAmount', amount(options[:trial_tax_amount] || 0), 'currencyID' => options[:currency] || 'USD' unless options[:trial_tax_amount].blank?
                    xml.tag! 'n2:ShippingAmount', amount(options[:trial_shipping_amount] || 0), 'currencyID' => options[:currency] || 'USD' unless options[:trial_shipping_amount].blank?
                  end
                end
                if !options[:initial_amount].blank?
                  xml.tag! 'n2:ActivationDetails' do
                    xml.tag! 'n2:InitialAmount', amount(options[:initial_amount]), 'currencyID' => options[:currency] || 'USD'
                    xml.tag! 'n2:FailedInitialAmountAction', options[:continue_on_failure] ? 'ContinueOnFailure' : 'CancelOnFailure'
                  end
                end
                xml.tag! 'n2:MaxFailedPayments', options[:max_failed_payments] unless options[:max_failed_payments].blank?
                xml.tag! 'n2:AutoBillOutstandingAmount', options[:auto_bill_outstanding] ? 'AddToNextBilling' : 'NoAutoBill'
              end
              add_payment_details_items_xml(xml, options, currency_code)
            end
          end
        end
        xml.target!
      end

    end
  end
end

if defined?(ActiveMerchant::Billing::PaypalExpressGateway)
  ActiveMerchant::Billing::PaypalExpressGateway.send(:include, ActiveMerchant::Billing::PaypalRecurring)
end
