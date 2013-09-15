module Stripe
  module CLI
    module Commands
      class Tokens < Command

        desc "find ID", "Find a Token`"
        def find event_id
          super Stripe::Event, event_id
        end

        desc "create TYPE", "create a new token of type TYPE(card or account)"
        option :card, :type => :hash
        option :card_name
        option :card_number
        option :card_cvc
        option :card_exp_month
        option :card_exp_year
        option :bank_account, :type => :hash
        option :country
        option :routing_number
        option :account_number
        def create type
          case type
          when 'card', 'credit_card'
            unless options[:card]
              options[:card_name]      ||= ask('Name on Card:')
              options[:card_number]    ||= ask('Card number:')
              options[:card_cvc]       ||= ask('CVC code:')
              options[:card_exp_month] ||= ask('expiration month:')
              options[:card_exp_year]  ||= ask('expiration year:')

              options[:card] = {
                :number    => options.delete(:card_number),
                :exp_month => options.delete(:card_exp_month),
                :exp_year  => options.delete(:card_exp_year),
                :cvc       => options.delete(:card_cvc),
                :name      => options.delete(:card_name)
              }
              options.delete(:bank_account)
              options.delete(:country)
              options.delete(:routing_number)
              options.delete(:account_number)
            end
          when 'account', 'bank_account'
            unless options[:bank_account]
              options[:account_number] ||= ask('Account Number:')
              options[:routing_number] ||= ask('Routing Number:')
              options[:country]        ||= 'US'

              options[:bank_account] = {
                :account_number => options.delete(:account_number),
                :routing_number => options.delete(:routing_number),
                :country => options.delete(:country)
              }
              options.delete(:card)
              options.delete(:card_name)
              options.delete(:card_number)
              options.delete(:card_cvc)
              options.delete(:card_exp_month)
              options.delete(:card_exp_year)
            end
          end

          super Stripe::Token, options
        end

      end
    end
  end
end